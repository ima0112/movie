// ignore_for_file: prefer_initializing_formals
import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/genre.dart';
import '../../../../core/domain/entities/media_key.dart';
import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/domain/entities/result.dart';
import '../../../../core/domain/entities/surprise_history_entry.dart';
import '../../../../core/domain/entities/user_media_entry.dart';
import '../../../../core/domain/repositories/surprise_history_repository.dart';
import '../../../../core/domain/repositories/taste_profile_repository.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../match_engine/domain/participant_answers.dart';
import '../../../match_engine/domain/surprise_batch.dart';
import '../../../match_engine/domain/surprise_engine.dart';
import '../../../match_engine/domain/surprise_request.dart';
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
    this._engine,
    this._tasteProfileBuilder,
    this._tasteProfileRepository,
    this._userLibraryRepository, {
    this.participantId = 'me',
    SurpriseHistoryRepository? history,
    String Function()? region,
    Random? random,
    DateTime Function()? clock,
  }) : _history = history,
       _region = region ?? (() => 'US'),
       _random = random ?? Random(),
       _clock = clock ?? DateTime.now,
       super(const ChoosingType());

  final SurpriseEngine _engine;
  final TasteProfileBuilder _tasteProfileBuilder;
  final TasteProfileRepository _tasteProfileRepository;
  final UserLibraryRepository _userLibraryRepository;

  /// What Surprise me has shown, kept on the device (`null` = not kept:
  /// only this session's own titles are skipped).
  final SurpriseHistoryRepository? _history;

  /// The user's region (Settings → Region), read at each search.
  final String Function() _region;
  final Random _random;
  final DateTime Function() _clock;

  /// Surprise-me is always N=1 — nothing in E1/E3 lets this vary, so
  /// unlike `QuizScreen` (which the Matcher will eventually override),
  /// this has no real caller that would ever need a different value
  /// yet. Still a parameter, not a hardcoded literal, for the same
  /// "don't bake in an identity this Cubit has no business choosing"
  /// reason `QuizCubit.buildAnswers` already keeps it one.
  final String participantId;

  /// A redone questionnaire also skips what Surprise me showed in this many
  /// days (`docs/DECISIONS.md` §5).
  static const Duration recentWindow = Duration(days: 30);

  /// "Searching…" never flashes for less than this, even if
  /// [SurpriseEngine.resolve] is instant.
  static const Duration minSearchingDuration = Duration(milliseconds: 1800);

  /// Past this, [_search] gives up and emits [SurpriseError] instead of
  /// continuing to wait on [SurpriseEngine.resolve].
  static const Duration maxSearchingDuration = Duration(seconds: 8);

  int _searchGeneration = 0;

  // Remembered so retry() can re-run the exact same search regardless of
  // whether it originally came from chooseType() or answerWith() — a
  // transient engine failure has nothing to do with re-deciding which of
  // DECISIONS.md's 3 cases applies.
  MediaType? _lastMediaType;
  ParticipantAnswers? _lastAnswers;
  SuggestionSource? _lastSource;

  /// Set by [chooseType] right before emitting [ChooseSource], read by
  /// [useMyTastes] once the user actually picks it — built once,
  /// up front, rather than re-running [TasteProfileBuilder.build] a
  /// second time from scratch.
  ParticipantAnswers? _pendingAnswers;

  /// The Surprise-me session ("shuffle"): one per fresh ask (a type chosen and
  /// tastes or quiz answered); [retry] and "other 5" keep it, so what it
  /// already showed is never suggested again.
  String _sessionId = '';
  final Set<MediaKey> _sessionShown = {};

  /// Taste for the engine: the library's genre affinity plus the profile's
  /// liked genres. Computed in [chooseType], where both are at hand.
  Map<Genre, int> _genreAffinity = const {};

  static const int _profileLikedWeight = 3;

  /// E1's "First tap: movie or TV show?" — resolves which of
  /// `docs/DECISIONS.md`'s 3 cases applies (usable profile / inferred
  /// from the list / neither). The first two no longer launch the
  /// engine directly: they emit [ChooseSource] so E1 can offer H11
  /// ("Use my tastes" vs "Answer the quiz instead") first — only the
  /// third case ([NeedsQuiz]) is still immediate, since there's no
  /// usable signal to offer a choice about. Doesn't emit [Searching]
  /// at all: that only starts once [useMyTastes]/[answerWith] actually
  /// launches a search, not while this is still deciding which case
  /// applies.
  Future<void> chooseType(MediaType mediaType) async {
    final generation = ++_searchGeneration;

    final profile = await _tasteProfileRepository.watch().first;
    final libraryEntries = await _libraryEntries();
    if (generation != _searchGeneration || isClosed) return;

    _genreAffinity = {
      ...genreAffinityFrom(libraryEntries),
      if (profile != null)
        for (final g in profile.likedGenres)
          g: (genreAffinityFrom(libraryEntries)[g] ?? 0) + _profileLikedWeight,
    };

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

    final source = (profile?.isUsableForSuggestions ?? false)
        ? SuggestionSource.profile
        : SuggestionSource.inferredList;
    _pendingAnswers = answers;
    emit(
      ChooseSource(
        mediaType,
        source,
        tasteGenres: source == SuggestionSource.profile
            ? profile!.likedGenres
            : const {},
      ),
    );
  }

  /// H11's own "Use my tastes" — launches the search [chooseType]
  /// already built the answers for. A no-op from any state other than
  /// [ChooseSource]; per that state's own doc comment, [_pendingAnswers]
  /// is always set by the time this can actually run.
  Future<void> useMyTastes() async {
    final current = state;
    if (current is! ChooseSource) return;
    final answers = _pendingAnswers;
    if (answers == null) return;

    final generation = ++_searchGeneration;
    emit(Searching(current.mediaType));
    await _search(
      current.mediaType,
      answers,
      current.source,
      generation,
      newSession: true,
    );
  }

  /// H11's own "Answer the quiz instead" — the user had a usable
  /// signal but chose to answer E2 anyway. A no-op from any state
  /// other than [ChooseSource].
  void answerQuizInstead() {
    final current = state;
    if (current is! ChooseSource) return;
    emit(NeedsQuiz(current.mediaType));
  }

  /// E2's own `onComplete` callback, once the quiz (opened from
  /// [NeedsQuiz] — whether [chooseType] went straight there, or
  /// [answerQuizInstead] sent it there from [ChooseSource]) finishes.
  /// A no-op from any other state — there's nothing to answer if the
  /// quiz was never the one asked for.
  Future<void> answerWith(ParticipantAnswers answers) async {
    final current = state;
    if (current is! NeedsQuiz) return;

    final generation = ++_searchGeneration;
    final mediaType = current.mediaType;
    emit(Searching(mediaType));
    await _search(
      mediaType,
      answers,
      SuggestionSource.quiz,
      generation,
      newSession: true,
    );
  }

  /// E3's "Another suggestion" — rotates to the next candidate in the
  /// *already-fetched* pool (`MatchOptions.randomizeTop`'s whole top-5)
  /// without calling [MatchEngine] again. Once every candidate has been
  /// shown, emits [Exhausted] instead. A no-op from any state other than
  /// [SurpriseResult].
  void another() {
    final current = state;
    if (current is! SurpriseResult) return;

    // Asked for another without picking this one.
    unawaited(_markOutcome(current.current.key, SurpriseOutcome.discarded));

    final nextIndex = current.index + 1;
    if (nextIndex >= current.suggestions.length) {
      emit(const Exhausted());
      return;
    }

    emit(
      SurpriseResult(
        suggestions: current.suggestions,
        index: nextIndex,
        relaxations: current.relaxations,
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

  /// The user did something with the suggestion on screen — saved it to
  /// Watch later, opened its details: kept in the history as a taste signal.
  /// A no-op outside a result.
  void recordOutcome(SurpriseOutcome outcome) {
    final current = state;
    if (current is! SurpriseResult) return;
    unawaited(_markOutcome(current.current.key, outcome));
  }

  Future<void> _markOutcome(MediaKey key, SurpriseOutcome outcome) async {
    await _history?.setOutcome(
      sessionId: _sessionId,
      key: key,
      outcome: outcome,
    );
  }

  /// E3a's "×": gives up the search in flight — whatever it finds is thrown
  /// away — and goes back to [ChoosingType], so E1 can route again when the
  /// user picks a type once more.
  void cancelSearch() {
    _searchGeneration++;
    emit(const ChoosingType());
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
    int generation, {
    bool newSession = false,
  }) async {
    _lastMediaType = mediaType;
    _lastAnswers = answers;
    _lastSource = source;
    if (newSession || _sessionId.isEmpty) {
      _sessionId =
          '${_clock().microsecondsSinceEpoch}-${_random.nextInt(1 << 31)}';
      _sessionShown.clear();
    }

    final excluded = {
      ..._sessionShown,
      if (answers.excludeWatched) ...answers.watchedKeys,
    };
    final recent = await _history?.shownKeys(
      mediaType,
      since: _clock().subtract(recentWindow),
    );
    if (recent case Success<Set<MediaKey>>(:final value)) {
      excluded.addAll(value);
    }
    if (generation != _searchGeneration || isClosed) return;

    final request = SurpriseRequest(
      type: mediaType,
      answers: answers,
      sessionId: _sessionId,
      region: _region(),
      seed: _random.nextInt(1 << 31),
      excludeKeys: excluded,
      genreAffinity: _genreAffinity,
    );

    // Future.wait races the engine against the minimum delay — the combined
    // wait is whichever of the two takes longer, not their sum. .timeout()
    // wraps that whole wait so a slow engine can't push past the maximum
    // either.
    final resolveFuture = _engine.resolve(
      request,
      vibeCatalog: _tasteProfileBuilder.vibeCatalog,
    );
    final delayFuture = Future<Object?>.delayed(minSearchingDuration);

    Result<SurpriseBatch>? result;
    try {
      final results = await Future.wait<Object?>([
        resolveFuture,
        delayFuture,
      ]).timeout(maxSearchingDuration, onTimeout: () => [null, null]);
      result = results[0] as Result<SurpriseBatch>?;
    } catch (_) {
      result = null;
    }

    if (generation != _searchGeneration || isClosed) return;

    if (result is! Success<SurpriseBatch>) {
      emit(const SurpriseError());
      return;
    }
    final batch = result.value;

    if (batch.isEmpty) {
      // Nothing (more) that satisfies the filters: after earlier batches
      // that's "that's all for now"; on a first search, no match at all.
      emit(_sessionShown.isEmpty ? const SurpriseError() : const Exhausted());
      return;
    }

    final keys = {for (final s in batch.suggestions) s.item.key};
    _sessionShown.addAll(keys);
    final now = _clock();
    unawaited(
      _history?.recordShown([
            for (final key in keys)
              SurpriseHistoryEntry(
                key: key,
                sessionId: _sessionId,
                shownAt: now,
              ),
          ]) ??
          Future<void>.value(),
    );

    emit(
      SurpriseResult(
        suggestions: batch.suggestions,
        index: 0,
        relaxations: batch.relaxations,
        source: source,
      ),
    );
  }
}
