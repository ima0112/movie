import 'dart:math';

import 'package:injectable/injectable.dart';

import '../../../core/domain/entities/discover_filter.dart';
import '../../../core/domain/entities/genre.dart';
import '../../../core/domain/entities/genre_catalog.dart';
import '../../../core/domain/entities/media_item.dart';
import '../../../core/domain/entities/media_key.dart';
import '../../../core/domain/entities/media_type.dart';
import '../../../core/domain/entities/result.dart';
import '../../../core/domain/repositories/media_repository.dart';
import 'match_query.dart';
import 'match_result.dart';
import 'relaxation.dart';
import 'vibe.dart';
import 'vibe_catalog.dart';

/// Per-call configuration [MatchEngine.resolve] needs beyond the
/// [MatchQuery] itself.
class MatchOptions {
  const MatchOptions({
    required this.vibeCatalog,
    this.alternativesCount = 3,
    this.randomizeTop,
  });

  /// Resolves each `MatchQuery.vibeWeights` id back to a [Vibe], for that
  /// vibe's own genre/keyword/year/rating rule. Not constructor-injected
  /// into [MatchEngineImpl] directly: loading it (`VibeCatalog
  /// .loadFromAssets`) is async and nothing wires it through `get_it`
  /// yet — whoever calls [MatchEngine.resolve] is already holding one.
  final VibeCatalog vibeCatalog;

  /// `docs/DECISIONS.md`'s own "alternatives[3–4]" — a range, not a
  /// fixed count; this picks the low end as the default. Ignored when
  /// [randomizeTop] is set — see that field's own doc comment.
  final int alternativesCount;

  /// When set, [MatchEngineImpl] picks the winner at random from among
  /// the top [randomizeTop] scored candidates instead of deterministically
  /// the single best one — `docs/DECISIONS.md`'s own "Surprise me"
  /// closing line: "The engine picks with some randomness among the
  /// top-5 scored so 'Surprise me' doesn't repeat." Every other
  /// candidate from that same pool becomes `alternatives`, so the full
  /// pool (winner + alternatives) is exactly `min(randomizeTop,
  /// however many candidates actually came back)` — `SurpriseCubit
  /// .another()` rotates through that whole pool locally rather than
  /// calling [MatchEngine.resolve] again. `null` (the Matcher's own
  /// case, unaffected by this) keeps today's deterministic behavior.
  final int? randomizeTop;
}

/// Pure domain service — `docs/DECISIONS.md` section 5: "Pure domain
/// service: no Flutter, no Firebase, no direct network access (only the
/// `MediaRepository` interface). Covered by unit tests. Used by both
/// Surprise me (N=1, local) and the Matcher (N≥2, Firebase)."
abstract interface class MatchEngine {
  /// Resolves one [MatchQuery] into a [MatchResult], applying the
  /// relaxation ladder (`relaxation.dart`) as needed.
  ///
  /// Returns `null` only if every step of the ladder is exhausted and
  /// there's still not a single candidate — `docs/DECISIONS.md`'s own
  /// "There is always a result" is a guarantee about the real,
  /// TMDB-backed search space (~a million titles), not one this method
  /// can make unconditionally against an arbitrary `MediaRepository` (a
  /// small `FakeMediaRepository` fixture, in particular, can genuinely
  /// run out).
  Future<MatchResult?> resolve(
    MatchQuery query, {
    required MatchOptions options,
  });
}

/// See [MatchEngine]'s own doc comment for the contract. Strategy per
/// `docs/DECISIONS.md` section 5 ("Fetching candidates" / "Scoring"):
///
/// - **One `MediaRepository.discover` call per requested vibe**, not one
///   per candidate — each call's [DiscoverFilter.withGenres]/
///   [DiscoverFilter.withKeywords] are that vibe's own genre/keyword
///   rule for [MatchQuery.mediaType], plus every hard filter
///   [MatchQuery] carries. A candidate can surface from more than one
///   vibe's call; [_fetchAndScore] merges by id and remembers every
///   vibe it matched under.
/// - **Score** = the sum of [MatchQuery.vibeWeights] for every vibe a
///   candidate matched, minus a flat penalty if it's in
///   [MatchQuery.watchedByAnyone]. Ties are broken by `voteAverage`
///   (descending) as a separate sort key, not blended into one number —
///   `docs/DECISIONS.md`'s own "bonus for vote_average" reads naturally
///   either way, and a separate key is the only way to make "several
///   candidates tie and vote_average breaks it" an exact, deterministic
///   outcome rather than a question of how big the bonus constant is.
/// - A candidate in [MatchQuery.excludedWatchedKeys] is dropped before
///   scoring entirely — that's the hard exclusion; [watchedByAnyone] is
///   the separate, softer signal that only nudges score.
///
/// **One field `MatchQuery` carries but this implementation still
/// can't act on**, an already-documented, pre-existing gap in the
/// underlying contract, not a new one: [MatchQuery.maxSeasons] —
/// `MediaItem` (the list-level entity `discover()` returns) carries no
/// season-count data, and `DiscoverFilter` has no such field either
/// (H8/C1 never needed one). Relaxation step 3's TV branch still
/// produces a new `MatchQuery` with this field updated (for whenever
/// that changes), but it has no effect on which candidates come back
/// yet. [MatchQuery.voteCountGte] is no longer in this category —
/// [_filterForVibe] passes it straight through to
/// `DiscoverFilter.minVoteCount` now.
///
/// This gap doesn't block movies (`maxRuntimeMinutes` *is* wired into
/// `DiscoverFilter`, though `FakeMediaRepository` specifically can't act
/// on it either — see that field's own doc comment) or TV's `tvStatus`
/// (wired and honored by `FakeMediaRepository.discover`).
@LazySingleton(as: MatchEngine)
class MatchEngineImpl implements MatchEngine {
  MatchEngineImpl(this._mediaRepository, [Random? random])
    : _random = random ?? Random();

  final MediaRepository _mediaRepository;

  /// Injectable (defaults to a real one) so [MatchOptions.randomizeTop]'s
  /// winner pick is reproducible in tests — see this class's own test
  /// file for a seeded instance.
  final Random _random;

  /// Relaxation step 3's runtime increase, in minutes. Not a value
  /// `docs/DECISIONS.md` specifies ("Raise runtime / season limit" names
  /// the step, not a magnitude) — chosen to be a meaningful jump without
  /// being the same as removing the cap outright.
  static const int _runtimeIncreaseMinutes = 30;

  /// Relaxation step 3's season-limit increase. Same "docs name the step,
  /// not a magnitude" reasoning as [_runtimeIncreaseMinutes].
  static const int _seasonsIncrease = 2;

  static const int _relaxedVoteCountGte = 50;

  @override
  Future<MatchResult?> resolve(
    MatchQuery query, {
    required MatchOptions options,
  }) async {
    var currentQuery = query;
    final relaxationsApplied = <Relaxation>[];

    var scored = await _fetchAndScore(currentQuery, options.vibeCatalog);

    for (final step in Relaxation.values) {
      if (scored.isNotEmpty) break;

      final relaxedQuery = _applyRelaxation(step, currentQuery);
      if (relaxedQuery == null) continue; // step doesn't apply — try the next

      currentQuery = relaxedQuery;
      relaxationsApplied.add(step);
      scored = await _fetchAndScore(currentQuery, options.vibeCatalog);
    }

    if (scored.isEmpty) return null;

    return _buildResult(
      scored,
      currentQuery,
      relaxationsApplied,
      options.alternativesCount,
      options.randomizeTop,
    );
  }

  Future<List<_ScoredCandidate>> _fetchAndScore(
    MatchQuery query,
    VibeCatalog vibeCatalog,
  ) async {
    final candidatesById = <int, MediaItem>{};
    final matchedVibesById = <int, Set<String>>{};

    for (final vibeId in query.vibeWeights.keys) {
      final vibe = vibeCatalog.byId(vibeId);
      if (vibe == null || !vibe.isMeaningfulFor(query.mediaType)) continue;

      final result = await _mediaRepository.discover(
        _filterForVibe(vibe, query),
      );
      final items = switch (result) {
        Success<List<MediaItem>>(:final value) => value,
        Failure<List<MediaItem>>() => const <MediaItem>[],
      };

      for (final item in items) {
        final key = MediaKey(type: item.type, tmdbId: item.id);
        if (query.excludedWatchedKeys.contains(key)) continue;

        candidatesById[item.id] = item;
        (matchedVibesById[item.id] ??= {}).add(vibeId);
      }
    }

    final scored = [
      for (final entry in candidatesById.entries)
        _score(entry.value, matchedVibesById[entry.key]!, query),
    ];

    scored.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      return b.item.voteAverage.compareTo(a.item.voteAverage);
    });

    return scored;
  }

  DiscoverFilter _filterForVibe(Vibe vibe, MatchQuery query) {
    final rule = vibe.ruleFor(query.mediaType);
    final genres = rule.genreIds.map(_genreById).whereType<Genre>().toSet();
    // VibeRule.keywordIds is a List<String> (vibes.json's own JSON
    // shape — see its doc comment); a real TMDB keyword id is numeric,
    // so this parses each one.
    final keywordIds = rule.keywordIds.map(int.parse).toSet();

    return DiscoverFilter(
      type: query.mediaType,
      withGenres: genres,
      withoutGenres: query.excludedGenres,
      withKeywords: keywordIds,
      yearFrom: query.yearFrom,
      yearTo: vibe.maxReleaseYear,
      minVoteAverage: vibe.minVoteAverage,
      maxRuntimeMinutes: query.mediaType == MediaType.movie
          ? query.maxRuntimeMinutes
          : null,
      tvStatus: query.mediaType == MediaType.tvShow ? query.tvStatus : null,
      sortBy: DiscoverSortBy.popularity,
      minVoteCount: query.voteCountGte,
    );
  }

  Genre? _genreById(String id) {
    for (final genre in GenreCatalog.all) {
      if (genre.id == id) return genre;
    }
    return null;
  }

  _ScoredCandidate _score(
    MediaItem item,
    Set<String> matchedVibeIds,
    MatchQuery query,
  ) {
    final vibeScore = matchedVibeIds.fold<int>(
      0,
      (sum, id) => sum + (query.vibeWeights[id] ?? 0),
    );
    final key = MediaKey(type: item.type, tmdbId: item.id);
    final watchedPenalty = query.watchedByAnyone.contains(key) ? 1 : 0;

    return _ScoredCandidate(
      item: item,
      matchedVibeIds: matchedVibeIds,
      score: vibeScore - watchedPenalty,
    );
  }

  MatchResult _buildResult(
    List<_ScoredCandidate> scored,
    MatchQuery query,
    List<Relaxation> relaxationsApplied,
    int alternativesCount,
    int? randomizeTop,
  ) {
    final _ScoredCandidate winner;
    final List<MediaItem> alternatives;

    if (randomizeTop != null && randomizeTop > 1) {
      final poolSize = min(randomizeTop, scored.length);
      final winnerIndex = _random.nextInt(poolSize);
      winner = scored[winnerIndex];
      alternatives = [
        for (var i = 0; i < poolSize; i++)
          if (i != winnerIndex) scored[i].item,
      ];
    } else {
      winner = scored.first;
      alternatives = scored
          .skip(1)
          .take(alternativesCount)
          .map((c) => c.item)
          .toList();
    }

    final satisfaction = [
      for (final entry in query.vibeIdsByParticipant.entries)
        Satisfaction(
          participantId: entry.key,
          vibesRequested: entry.value.length,
          vibesMet: entry.value.where(winner.matchedVibeIds.contains).length,
        ),
    ];

    return MatchResult(
      winner: winner.item,
      alternatives: alternatives,
      satisfaction: satisfaction,
      relaxationsApplied: relaxationsApplied,
    );
  }

  /// `null` means "this step doesn't apply to [query]" (e.g. there's no
  /// vibe left to drop, or the cap it would raise is already unlimited)
  /// — [resolve] skips straight to the next step without re-fetching.
  MatchQuery? _applyRelaxation(Relaxation step, MatchQuery query) {
    switch (step) {
      case Relaxation.dropLeastSupportedVibe:
        if (query.vibeWeights.length <= 1) return null;
        var leastSupportedId = query.vibeWeights.keys.first;
        for (final entry in query.vibeWeights.entries) {
          if (entry.value < query.vibeWeights[leastSupportedId]!) {
            leastSupportedId = entry.key;
          }
        }
        final newWeights = Map<String, int>.from(query.vibeWeights)
          ..remove(leastSupportedId);
        return query.copyWith(vibeWeights: newWeights);

      case Relaxation.widenYearRange:
        return query.copyWith(yearFrom: query.yearFrom - 10);

      case Relaxation.raiseRuntimeOrSeasonLimit:
        if (query.mediaType == MediaType.movie) {
          final runtime = query.maxRuntimeMinutes;
          if (runtime == null) return null;
          return query.copyWith(
            maxRuntimeMinutes: () => runtime + _runtimeIncreaseMinutes,
          );
        }
        final seasons = query.maxSeasons;
        if (seasons == null) return null;
        return query.copyWith(maxSeasons: () => seasons + _seasonsIncrease);

      case Relaxation.lowerVoteCountThreshold:
        if (query.voteCountGte <= _relaxedVoteCountGte) return null;
        return query.copyWith(voteCountGte: _relaxedVoteCountGte);
    }
  }
}

class _ScoredCandidate {
  const _ScoredCandidate({
    required this.item,
    required this.matchedVibeIds,
    required this.score,
  });

  final MediaItem item;
  final Set<String> matchedVibeIds;
  final int score;
}
