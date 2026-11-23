// ignore_for_file: prefer_initializing_formals
import '../../../../core/domain/repositories/surprise_session_repository.dart';
import '../../../../core/domain/entities/surprise_session.dart';
import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/data/assets/collection_catalog_loader.dart';
import '../../../../core/domain/entities/collection_catalog.dart';
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
import '../../../match_engine/domain/surprise_history_affinity.dart';
import '../../../match_engine/domain/surprise_request.dart';
import '../../../taste_profile/domain/taste_profile_builder.dart';
import 'surprise_state.dart';
import 'surprise_watch_later.dart';

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
    SurpriseSessionRepository? sessions,
    String Function()? region,
    Random? random,
    DateTime Function()? clock,
  }) : _history = history,
       _sessions = sessions,
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

  /// What each session asked for, kept beside the history (`null` = not kept).
  final SurpriseSessionRepository? _sessions;

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

  /// The batch of this session on screen (1 = the first five, 2 = after one
  /// "other 5"…); 0 before the first.
  int _batch = 0;

  /// Taste for the engine: the library's genre affinity plus the profile's
  /// liked genres. Computed in [chooseType], where both are at hand.
  Map<Genre, int> _baseAffinity = const {};

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

    // A fresh pick starts from "choosing": E1 routes once per pick (to H11, the
    // quiz or the result), and it only knows a pick is new when the state
    // passes through [ChoosingType]. Without this, coming back to E1 from the
    // quiz (or H11, or the result) left the state at [NeedsQuiz] and E1 still
    // "already navigated" — the cards did nothing.
    if (state is! ChoosingType) emit(const ChoosingType());

    final profile = await _tasteProfileRepository.watch().first;
    final libraryEntries = await _libraryEntries();
    if (generation != _searchGeneration || isClosed) return;

    _baseAffinity = {
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

  // ---------------------------------------------------------------- the deck

  /// How long a card on top counts as "lingered on" (weakly positive).
  static const Duration dwellDuration = Duration(seconds: 3);

  Timer? _dwell;

  /// Which cards of the batch on screen have been on top (so one that comes
  /// back — the deck is circular — or is jumped to counts as revisited).
  final Set<int> _visited = {};

  /// While "other 5" is running over a deck: what to go back to if it finds
  /// nothing or can't reach TMDB — the deck is never lost to a failed ask.
  SurpriseResult? _deckBeforeReroll;

  bool _choosing = false;

  /// Pass: the next card comes up (after the last, the first — the deck never
  /// runs out). With one card there is nowhere to go. Never a rejection.
  void next() {
    final deck = state;
    if (deck is! SurpriseResult || deck.suggestions.length < 2) return;
    _showCard(deck, (deck.index + 1) % deck.suggestions.length);
  }

  /// Save the card on top to Watch later, staying on it (the accessible "Save"
  /// control); a no-op if it is already there.
  Future<void> save() async {
    final deck = state;
    if (deck is! SurpriseResult) return;
    await _saveCard(deck.index);
  }

  /// The Watch later button of the card for [key]: in → out, out → in. The deck
  /// shows the change at once and takes it back if the write fails. Saving
  /// counts as a taste signal (`saved`); taking it out again does not undo it.
  Future<void> toggleSaved(MediaKey key) async {
    final deck = state;
    if (deck is! SurpriseResult) return;
    final i = deck.suggestions.indexWhere((s) => s.item.key == key);
    if (i < 0) return;
    if (!deck.savedKeys.contains(key)) return _saveCard(i);

    emit(deck.copyWith(savedKeys: {...deck.savedKeys}..remove(key)));
    final result = await removeFromWatchLater(_userLibraryRepository, key);
    if (result is Failure<void> && !isClosed) {
      final now = state;
      if (now is SurpriseResult) {
        emit(now.copyWith(savedKeys: {...now.savedKeys, key}));
      }
    }
  }

  /// Bring card [index] to the top (a thumbnail tapped).
  void jumpTo(int index) {
    final deck = state;
    if (deck is! SurpriseResult ||
        index < 0 ||
        index >= deck.suggestions.length ||
        index == deck.index) {
      return;
    }
    _showCard(deck, index);
  }

  /// Pick the card on top (double tap, or "Choose this" from its detail): it
  /// goes into Watch later by itself, is recorded as chosen, and the game ends
  /// at the closing screen. A second call while this one is running is ignored.
  Future<void> choose() async {
    final deck = state;
    if (deck is! SurpriseResult || _choosing) return;
    _choosing = true;
    _dwell?.cancel();
    final index = deck.index;
    final card = deck.suggestions[index];
    try {
      await saveToWatchLater(_userLibraryRepository, card);
      if (isClosed || state is! SurpriseResult) return;
      unawaited(_markOutcome(card.item.key, SurpriseOutcome.chosen));
      emit(
        SurpriseChosen(
          suggestions: deck.suggestions,
          index: index,
          savedKeys: {...(state as SurpriseResult).savedKeys, card.item.key},
          source: deck.source,
        ),
      );
    } finally {
      _choosing = false;
    }
  }

  /// "Other 5": a new batch with the same answers and no title of the session
  /// repeated. The deck stays on screen under "Searching" and **comes back**
  /// if the ask finds nothing new or can't reach TMDB (with a [notice]).
  Future<void> reroll() async {
    final deck = state;
    final mediaType = _lastMediaType;
    final answers = _lastAnswers;
    final source = _lastSource;
    if (deck is! SurpriseResult ||
        mediaType == null ||
        answers == null ||
        source == null) {
      return;
    }
    _dwell?.cancel();
    _deckBeforeReroll = deck;
    final generation = ++_searchGeneration;
    emit(Searching(mediaType));
    await _search(mediaType, answers, source, generation);
  }

  /// [SurpriseError]'s own recovery — re-runs the search that failed (same
  /// type, same answers, same source). A no-op if nothing was searched yet.
  Future<void> retry() async {
    final mediaType = _lastMediaType;
    final answers = _lastAnswers;
    final source = _lastSource;
    if (mediaType == null || answers == null || source == null) return;

    final generation = ++_searchGeneration;
    emit(Searching(mediaType));
    await _search(mediaType, answers, source, generation);
  }

  /// The user left the deck (the ×): stops the "lingered on" timer. The
  /// history was written event by event, so nothing else is left to save.
  void closeDeck() => _dwell?.cancel();

  /// The pending [SurpriseResult.notice] has been shown.
  void noticeShown() {
    final deck = state;
    if (deck is SurpriseResult && deck.notice != SurpriseNotice.none) {
      emit(deck.copyWith(notice: SurpriseNotice.none));
    }
  }

  /// The card on top was turned over to read its back: kept in the history as a
  /// taste signal (they wanted to know more about it).
  void cardFlipped() => recordOutcome(SurpriseOutcome.revisited);

  /// The user did something with the card on top — opened its details: kept in
  /// the history as a taste signal. A no-op outside a deck.
  void recordOutcome(SurpriseOutcome outcome) {
    final deck = state;
    if (deck is! SurpriseResult) return;
    unawaited(_markOutcome(deck.current.key, outcome));
  }

  Future<void> _markOutcome(MediaKey key, SurpriseOutcome outcome) async {
    await _history?.setOutcome(
      sessionId: _sessionId,
      key: key,
      outcome: outcome,
    );
  }

  /// A card comes to the top: one already seen in this batch counts as
  /// revisited, and the "lingered on" timer starts over.
  void _showCard(SurpriseResult deck, int index) {
    emit(deck.copyWith(index: index));
    final card = deck.suggestions[index];
    if (!_visited.add(index)) {
      unawaited(_markOutcome(card.item.key, SurpriseOutcome.revisited));
    }
    _startDwell();
  }

  void _startDwell() {
    _dwell?.cancel();
    _dwell = Timer(dwellDuration, () {
      final deck = state;
      if (deck is SurpriseResult) {
        unawaited(_markOutcome(deck.current.key, SurpriseOutcome.revisited));
      }
    });
  }

  /// Puts card [index] in Watch later (and the history). Optimistic: the deck
  /// shows it saved at once and goes back if the write fails.
  Future<void> _saveCard(int index) async {
    final deck = state;
    if (deck is! SurpriseResult) return;
    final card = deck.suggestions[index];
    final key = card.item.key;
    if (deck.savedKeys.contains(key)) return;

    emit(deck.copyWith(savedKeys: {...deck.savedKeys, key}));
    unawaited(_markOutcome(key, SurpriseOutcome.saved));
    final result = await saveToWatchLater(_userLibraryRepository, card);
    if (result is Failure<void> && !isClosed) {
      final now = state;
      if (now is SurpriseResult) {
        emit(now.copyWith(savedKeys: {...now.savedKeys}..remove(key)));
      }
    }
  }

  @override
  Future<void> close() {
    _dwell?.cancel();
    return super.close();
  }

  /// E3a's "×": gives up the search in flight — whatever it finds is thrown
  /// away — and goes back to [ChoosingType], so E1 can route again when the
  /// user picks a type once more.
  ///
  /// Over a deck ("other 5" was running) the deck comes back as it was and the
  /// call returns `true` — there is nowhere to go back *from*; otherwise it goes
  /// to [ChoosingType] and returns `false`.
  bool cancelSearch() {
    _searchGeneration++;
    final deck = _deckBeforeReroll;
    _deckBeforeReroll = null;
    if (deck != null) {
      _restoreDeck(deck, SurpriseNotice.none);
      return true;
    }
    _dwell?.cancel();
    emit(const ChoosingType());
    return false;
  }

  /// The taste for the engine: [_baseAffinity] (My List and the profile) plus
  /// what the history says — read at each search, so what was chosen, saved or
  /// revisited in this very session already counts for the next batch.
  Future<Map<Genre, int>> _affinityWithHistory() async {
    final history = await _history?.all();
    if (history is! Success<List<SurpriseHistoryEntry>>) return _baseAffinity;
    final learned = SurpriseHistoryAffinity.from(history.value, now: _clock());
    return {
      for (final genre in {..._baseAffinity.keys, ...learned.keys})
        genre: (_baseAffinity[genre] ?? 0) + (learned[genre] ?? 0),
    };
  }

  Future<List<UserMediaEntry>> _libraryEntries() async {
    final result = await _userLibraryRepository.all();
    return switch (result) {
      Success<List<UserMediaEntry>>(:final value) => value,
      Failure<List<UserMediaEntry>>() => const <UserMediaEntry>[],
    };
  }

  /// The engine's answer, handing it the collection catalog only when the
  /// answers name a collection (the common search never reads the asset).
  Future<Result<SurpriseBatch>> _resolveWithCollections(
    SurpriseRequest request,
  ) async {
    final collectionCatalog = request.answers.collectionIds.isEmpty
        ? const CollectionCatalog([])
        : await loadCollectionCatalog();
    return _engine.resolve(
      request,
      vibeCatalog: _tasteProfileBuilder.vibeCatalog,
      collectionCatalog: collectionCatalog,
    );
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
      _batch = 0;
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
      genreAffinity: await _affinityWithHistory(),
    );

    // Future.wait races the engine against the minimum delay — the combined
    // wait is whichever of the two takes longer, not their sum. .timeout()
    // wraps that whole wait so a slow engine can't push past the maximum
    // either.
    final resolveFuture = _resolveWithCollections(request);
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

    final deckBefore = _deckBeforeReroll;
    _deckBeforeReroll = null;

    if (result is! Success<SurpriseBatch>) {
      // Over a deck, a failed ask leaves the deck as it was (offline notice).
      if (deckBefore != null) {
        _restoreDeck(deckBefore, SurpriseNotice.offline);
      } else {
        emit(const SurpriseError());
      }
      return;
    }
    final batch = result.value;

    if (batch.isEmpty) {
      // Nothing (more) that satisfies the filters: over a deck it stays (with
      // a notice); on a first search there is simply no match.
      if (deckBefore != null) {
        _restoreDeck(deckBefore, SurpriseNotice.noMoreSurprises);
      } else {
        emit(const SurpriseError());
      }
      return;
    }

    // A new batch replaces the one before: that one is marked as rerolled
    // (a fact) if nothing in it was picked.
    if (_batch > 0) {
      unawaited(
        _history?.markBatchRerolled(sessionId: _sessionId, batch: _batch) ??
            Future<void>.value(),
      );
    }

    final keys = {for (final s in batch.suggestions) s.item.key};
    _sessionShown.addAll(keys);
    _batch++;
    final now = _clock();
    unawaited(
      _history?.recordShown([
            for (final s in batch.suggestions)
              SurpriseHistoryEntry(
                key: s.item.key,
                sessionId: _sessionId,
                shownAt: now,
                batch: _batch,
                genres: s.item.genres,
              ),
          ]) ??
          Future<void>.value(),
    );

    // What this session asked for, kept beside what it showed: the first batch
    // records the answers, a later one only adds the relaxations it needed.
    unawaited(
      _sessions?.recordBatch(
            SurpriseSession(
              sessionId: _sessionId,
              startedAt: now,
              mediaType: mediaType,
              source: switch (source) {
                SuggestionSource.profile => SurpriseSessionSource.profile,
                SuggestionSource.inferredList =>
                  SurpriseSessionSource.inferredList,
                SuggestionSource.quiz => SurpriseSessionSource.quiz,
              },
              yearFrom: answers.yearFrom,
              yearTo: answers.yearTo,
              collectionIds: answers.collectionIds,
              vibeIds: answers.vibeIds,
              excludedGenres: answers.excludedGenres,
              platformIds: answers.platformIds,
              relaxations: {for (final r in batch.relaxations) r.name},
            ),
          ) ??
          Future<void>.value(),
    );

    // Cards already in Watch later show as saved from the start.
    final library = await _libraryEntries();
    if (generation != _searchGeneration || isClosed) return;
    final saved = {
      for (final e in library)
        if (e.isWatchLater && keys.contains(e.key)) e.key,
    };

    _visited
      ..clear()
      ..add(0);
    emit(
      SurpriseResult(
        suggestions: batch.suggestions,
        index: 0,
        relaxations: batch.relaxations,
        source: source,
        savedKeys: saved,
        notice: batch.relaxations.isEmpty
            ? SurpriseNotice.none
            : SurpriseNotice.widenedSearch,
      ),
    );
    _startDwell();
  }

  void _restoreDeck(SurpriseResult deck, SurpriseNotice notice) {
    emit(deck.copyWith(notice: notice));
    _startDwell();
  }
}
