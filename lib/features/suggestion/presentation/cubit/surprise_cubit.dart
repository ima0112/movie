import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/domain/entities/result.dart';
import '../../../../core/domain/entities/user_media_entry.dart';
import '../../../../core/domain/repositories/taste_profile_repository.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../match_engine/domain/match_engine.dart';
import '../../../match_engine/domain/match_query.dart';
import '../../../match_engine/domain/match_result.dart';
import '../../../match_engine/domain/participant_answers.dart';
import '../../../taste_profile/domain/taste_profile_builder.dart';
import 'surprise_state.dart';

/// Surprise me (N=1)'s state machine — `docs/SCREENS.md` E1/E3,
/// `docs/DECISIONS.md` section 5 ("Surprise me (N=1)").
///
/// Screen-local (CLAUDE.md rule 10): a fresh instance per Surprise-me
/// session, created where E1's own `BlocProvider` sits, not registered
/// in `di.config.dart` — same convention `QuizCubit`/`FilteredListCubit`
/// already follow.
class SurpriseCubit extends Cubit<SurpriseState> {
  SurpriseCubit(
    this._matchEngine,
    this._tasteProfileBuilder,
    this._tasteProfileRepository,
    this._userLibraryRepository, {
    this.participantId = 'me',
  }) : super(const ChoosingType());

  final MatchEngine _matchEngine;
  final TasteProfileBuilder _tasteProfileBuilder;
  final TasteProfileRepository _tasteProfileRepository;
  final UserLibraryRepository _userLibraryRepository;

  /// Surprise-me is always N=1 — nothing in E1/E3 lets this vary, so
  /// unlike `QuizScreen` (which the Matcher will eventually override),
  /// this has no real caller that would ever need a different value
  /// yet. Still a parameter, not a hardcoded literal, for the same
  /// "don't bake in an identity this Cubit has no business choosing"
  /// reason `QuizCubit.buildAnswers` already keeps it one.
  final String participantId;

  /// `docs/DECISIONS.md`'s own "top-5" — how many of the best-scored
  /// candidates `MatchEngine` randomizes the winner among
  /// (`MatchOptions.randomizeTop`), and so the size of the pool
  /// [another] rotates through afterward.
  static const int poolSize = 5;

  /// "Searching…" never flashes for less than this, even if
  /// [MatchEngine.resolve] is instant.
  static const Duration minSearchingDuration = Duration(milliseconds: 1200);

  /// Past this, [_search] gives up and emits [SurpriseError] instead of
  /// continuing to wait on [MatchEngine.resolve].
  static const Duration maxSearchingDuration = Duration(seconds: 8);

  int _searchGeneration = 0;

  // Remembered so retry() can re-run the exact same search regardless of
  // whether it originally came from chooseType() or answerWith() — a
  // transient engine failure has nothing to do with re-deciding which of
  // DECISIONS.md's 3 cases applies.
  MediaType? _lastMediaType;
  ParticipantAnswers? _lastAnswers;
  SuggestionSource? _lastSource;

  /// E1's "First tap: movie or TV show?" — resolves which of
  /// `docs/DECISIONS.md`'s 3 cases applies (explicit profile / inferred
  /// from the list / neither) and either launches the engine directly
  /// (the first two) or emits [NeedsQuiz] (the third) for the caller to
  /// react to.
  Future<void> chooseType(MediaType mediaType) async {
    final generation = ++_searchGeneration;
    emit(Searching(mediaType));

    final profile = await _tasteProfileRepository.watch().first;
    final libraryEntries = await _libraryEntries();
    if (generation != _searchGeneration || isClosed) return;

    final answers = _tasteProfileBuilder.build(
      profile: profile,
      libraryEntries: libraryEntries,
      mediaType: mediaType,
      participantId: participantId,
    );

    if (answers == null) {
      emit(NeedsQuiz(mediaType));
      return;
    }

    final source = profile != null
        ? SuggestionSource.profile
        : SuggestionSource.inferredList;
    await _search(mediaType, answers, source, generation);
  }

  /// E2's own `onComplete` callback, once the quiz (opened from
  /// [NeedsQuiz]) finishes. A no-op from any other state — there's
  /// nothing to answer if the quiz was never the one asked for.
  Future<void> answerWith(ParticipantAnswers answers) async {
    final current = state;
    if (current is! NeedsQuiz) return;

    final generation = ++_searchGeneration;
    final mediaType = current.mediaType;
    emit(Searching(mediaType));
    await _search(mediaType, answers, SuggestionSource.quiz, generation);
  }

  /// E3's "Another suggestion" — rotates to the next candidate in the
  /// *already-fetched* pool (`MatchOptions.randomizeTop`'s whole top-5)
  /// without calling [MatchEngine] again. Once every candidate has been
  /// shown, emits [Exhausted] instead. A no-op from any state other than
  /// [SurpriseResult].
  void another() {
    final current = state;
    if (current is! SurpriseResult) return;

    final nextIndex = current.index + 1;
    if (nextIndex >= current.candidates.length) {
      emit(const Exhausted());
      return;
    }

    emit(
      SurpriseResult(
        candidates: current.candidates,
        index: nextIndex,
        relaxationsApplied: current.relaxationsApplied,
        source: current.source,
      ),
    );
  }

  /// [SurpriseError]'s own recovery — re-runs the exact search that just
  /// failed (same media type, same `ParticipantAnswers`, same
  /// [SuggestionSource]). A no-op if nothing has been searched for yet.
  Future<void> retry() async {
    final mediaType = _lastMediaType;
    final answers = _lastAnswers;
    final source = _lastSource;
    if (mediaType == null || answers == null || source == null) return;

    final generation = ++_searchGeneration;
    emit(Searching(mediaType));
    await _search(mediaType, answers, source, generation);
  }

  Future<List<UserMediaEntry>> _libraryEntries() async {
    final result = await _userLibraryRepository.all();
    return switch (result) {
      Success<List<UserMediaEntry>>(:final value) => value,
      Failure<List<UserMediaEntry>>() => const <UserMediaEntry>[],
    };
  }

  Future<void> _search(
    MediaType mediaType,
    ParticipantAnswers answers,
    SuggestionSource source,
    int generation,
  ) async {
    _lastMediaType = mediaType;
    _lastAnswers = answers;
    _lastSource = source;

    final query = MatchQuery.aggregate(mediaType, [answers]);
    final options = MatchOptions(
      vibeCatalog: _tasteProfileBuilder.vibeCatalog,
      randomizeTop: poolSize,
    );

    // Future.wait races the engine against the minimum delay — the
    // combined wait is whichever of the two takes longer, not their sum.
    // .timeout() wraps that whole wait so a slow engine can't push past
    // the maximum either.
    final resolveFuture = _matchEngine.resolve(query, options: options);
    final delayFuture = Future<MatchResult?>.delayed(
      minSearchingDuration,
      () => null,
    );

    MatchResult? result;
    try {
      final results = await Future.wait([
        resolveFuture,
        delayFuture,
      ]).timeout(maxSearchingDuration, onTimeout: () => [null, null]);
      result = results[0];
    } catch (_) {
      result = null;
    }

    if (generation != _searchGeneration || isClosed) return;

    if (result == null) {
      emit(const SurpriseError());
      return;
    }

    emit(
      SurpriseResult(
        candidates: [result.winner, ...result.alternatives],
        index: 0,
        relaxationsApplied: result.relaxationsApplied,
        source: source,
      ),
    );
  }
}
