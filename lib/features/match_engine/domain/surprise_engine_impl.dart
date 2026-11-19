import 'dart:math';

import 'package:injectable/injectable.dart';

import '../../../core/domain/entities/collection.dart';
import '../../../core/domain/entities/collection_catalog.dart';
import '../../../core/domain/entities/media_detail.dart';
import '../../../core/domain/entities/result.dart';
import '../../../core/domain/repositories/media_repository.dart';
import 'participant_answers.dart';
import 'surprise_batch.dart';
import 'surprise_platforms.dart';
import 'surprise_candidates.dart';
import 'surprise_engine.dart';
import 'surprise_request.dart';
import 'surprise_scoring.dart';
import 'vibe.dart';
import 'vibe_catalog.dart';

/// The Surprise-me engine (`docs/DECISIONS.md` §5, "Surprise me engine"):
///
/// 1. **Gather** 40–60 unique candidates — a query per chosen vibe plus a
///    general one, each with the request's hard filters, several random
///    pages each ([SurpriseCandidateSource]).
/// 2. **Relax**, only while fewer than [minCandidates] came back, one
///    [SurpriseRelaxation] at a time: fewer votes, no vibes, earlier years.
///    Vetoes, platforms, runtime and the latest year are never touched.
/// 3. **Score** and **select** five with diversity rules
///    ([SurpriseScoring]).
/// 4. **Detail** the five (runtime or seasons, tagline, providers) in
///    parallel; one that fails is replaced by the next-best candidate.
///
/// Reaches TMDB only through [MediaRepository]; deterministic for a given
/// [SurpriseRequest.seed] and repository.
@LazySingleton(as: SurpriseEngine)
class SurpriseEngineImpl implements SurpriseEngine {
  SurpriseEngineImpl(this._repository)
    : _source = SurpriseCandidateSource(_repository);

  final MediaRepository _repository;
  final SurpriseCandidateSource _source;

  /// Below this many candidates the next relaxation step is tried.
  static const int minCandidates = 15;

  /// At most this many vibes are queried (the quiz allows three).
  static const int maxVibes = 3;

  /// How far back the "widen years" step moves the earliest year.
  static const int yearsWidened = 10;

  static const int earliestYear = 1900;

  /// Rounds of replacing a suggestion whose detail call failed.
  static const int detailRounds = 2;

  @override
  Future<Result<SurpriseBatch>> resolve(
    SurpriseRequest request, {
    required VibeCatalog vibeCatalog,
    CollectionCatalog collectionCatalog = const CollectionCatalog([]),
  }) async {
    final rng = Random(request.seed);
    // The chosen collections that exist for this kind of title: a hard filter
    // no relaxation step ever touches.
    final collections = [
      for (final id in request.answers.collectionIds)
        if (collectionCatalog.byId(id) case final Collection c
            when c.isAvailableFor(request.type))
          c,
    ].take(ParticipantAnswers.maxCollections).toList();
    final vibes = [
      for (final id in request.answers.vibeIds)
        if (vibeCatalog.byId(id) case final Vibe vibe
            when vibe.isMeaningfulFor(request.type))
          vibe,
    ].take(maxVibes).toList();

    var state = SurpriseSearchState(
      minVoteCount: SurpriseSearchStateDefaults.voteCount,
      useVibes: true,
      yearFrom: request.answers.yearFrom,
    );
    final relaxations = <SurpriseRelaxation>[];
    var gather = await _source.gather(request, vibes, collections, state, rng);

    for (final step in SurpriseRelaxation.values) {
      if (gather.candidates.length >= minCandidates || gather.failure != null) {
        break;
      }
      final next = _relax(step, state, hasVibes: vibes.isNotEmpty);
      if (next == null) continue;
      state = next;
      relaxations.add(step);
      gather = await _source.gather(request, vibes, collections, state, rng);
    }

    if (gather.failure != null) return Failure(gather.failure!);

    final candidates = gather.candidates;
    if (candidates.isEmpty) {
      return Success(
        SurpriseBatch(
          sessionId: request.sessionId,
          suggestions: const [],
          relaxations: relaxations,
        ),
      );
    }

    final usedVibeIds = state.useVibes
        ? [for (final v in vibes) v.id]
        : <String>[];
    final scored = SurpriseScoring.score(
      candidates,
      request,
      chosenVibes: usedVibeIds.length,
      rng: rng,
    );
    final picks = SurpriseScoring.select(
      scored,
      count: request.count,
      vibeIds: usedVibeIds,
      likedGenres: {
        for (final e in request.genreAffinity.entries)
          if (e.value > 0) e.key,
      },
      rng: rng,
    );

    final suggestions = await _withDetails(request, scored, picks);
    if (suggestions == null) return Failure(FailureReason.network);

    return Success(
      SurpriseBatch(
        sessionId: request.sessionId,
        suggestions: suggestions,
        relaxations: relaxations,
        candidateCount: candidates.length,
      ),
    );
  }

  SurpriseSearchState? _relax(
    SurpriseRelaxation step,
    SurpriseSearchState state, {
    required bool hasVibes,
  }) => switch (step) {
    SurpriseRelaxation.lowerVoteCount =>
      state.minVoteCount <= SurpriseSearchStateDefaults.relaxedVoteCount
          ? null
          : state.copyWith(
              minVoteCount: SurpriseSearchStateDefaults.relaxedVoteCount,
            ),
    SurpriseRelaxation.dropVibes =>
      !hasVibes || !state.useVibes ? null : state.copyWith(useVibes: false),
    SurpriseRelaxation.widenYears =>
      state.yearFrom <= earliestYear
          ? null
          : state.copyWith(
              yearFrom: max(earliestYear, state.yearFrom - yearsWidened),
            ),
  };

  /// Details for [picks]; a pick whose call fails is replaced by the next
  /// best candidate not yet tried. `null` only when not one detail could be
  /// fetched at all (offline).
  Future<List<SurpriseSuggestion>?> _withDetails(
    SurpriseRequest request,
    List<ScoredCandidate> scored,
    List<ScoredCandidate> picks,
  ) async {
    final tried = {...picks};
    final queue = [...picks];
    final done = <(ScoredCandidate, MediaDetail)>[];
    var anySuccess = false;

    for (var round = 0; round <= detailRounds && queue.isNotEmpty; round++) {
      final results = await Future.wait([
        for (final c in queue)
          _repository.detail(c.candidate.key, regionCode: request.region),
      ]);
      var failed = 0;
      for (var i = 0; i < queue.length; i++) {
        switch (results[i]) {
          case Success<MediaDetail>(:final value):
            anySuccess = true;
            done.add((queue[i], value));
          case Failure<MediaDetail>():
            failed++;
        }
      }
      queue.clear();
      if (failed == 0) break;
      final spares = [...scored]..sort((a, b) => b.score.compareTo(a.score));
      for (final c in spares) {
        if (queue.length >= failed) break;
        if (tried.add(c)) queue.add(c);
      }
    }

    if (!anySuccess) return null;
    done.sort((a, b) => b.$1.score.compareTo(a.$1.score));
    return [
      for (final (c, detail) in done)
        SurpriseSuggestion(
          detail: detail,
          matchedVibeIds: c.candidate.vibeIds,
          platforms: platformsFor(detail.watchProviders, request.answers),
          affinityPercent: SurpriseScoring.percent(
            c.score,
            scored,
            SurpriseSuggestion.minPercent,
            SurpriseSuggestion.maxPercent,
          ),
        ),
    ].take(request.count).toList();
  }
}
