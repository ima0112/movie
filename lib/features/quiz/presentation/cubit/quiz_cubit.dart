import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/data/tmdb/tmdb_genre_mapper.dart';
import '../../../../core/domain/entities/collection.dart';
import '../../../../core/domain/entities/collection_catalog.dart';
import '../../../../core/domain/entities/discover_filter.dart'
    show DiscoverTvStatus;
import '../../../../core/domain/entities/genre.dart';
import '../../../../core/domain/entities/genre_catalog.dart';
import '../../../../core/domain/entities/media_key.dart';
import '../../../../core/domain/entities/media_type.dart';
import '../../../match_engine/domain/participant_answers.dart';
import '../../../match_engine/domain/vibe.dart';
import '../../../match_engine/domain/vibe_catalog.dart';
import '../../domain/quiz_options.dart';
import 'quiz_state.dart';

/// E2 (Quiz)'s state machine — `docs/SCREENS.md` E2: "1 screen, 4
/// steps... shared with the Matcher". Deliberately produces only a
/// [ParticipantAnswers] via [buildAnswers] and knows nothing about
/// Surprise me (E1/E3) or the Matcher (F2/F3) specifically — whichever
/// screen hosts this decides what to do with the result; this Cubit's
/// only job is collecting one person's answers.
///
/// Screen-local (CLAUDE.md rule 10): a fresh instance per quiz session,
/// created where E2's own `BlocProvider` sits, not registered in
/// `di.config.dart`.
///
/// Deliberately **not** handled here: E2's own "Use my tastes" button
/// (step 1, "fills answers in and jumps to step 4's confirmation").
/// That needs a `TasteProfile`, which would couple this Cubit to a
/// specific source of prior answers — out of scope for "produces a
/// ParticipantAnswers and hands it to whoever invoked it"; a future
/// screen can just call this Cubit's own setters with a profile's
/// values instead of this Cubit reaching for the profile itself.
class QuizCubit extends Cubit<QuizState> {
  // The fields are private, so the named parameters can't initialize them
  // directly.
  // ignore_for_file: prefer_initializing_formals
  QuizCubit(
    MediaType mediaType, {
    CollectionCatalog collectionCatalog = const CollectionCatalog([]),
    VibeCatalog vibeCatalog = const VibeCatalog([]),
    GenreOfTmdbId genreOf = TmdbGenreMapper.fromTmdbId,
  }) : _collectionCatalog = collectionCatalog,
       _vibeCatalog = vibeCatalog,
       _genreOf = genreOf,
       super(QuizState(mediaType: mediaType));

  final CollectionCatalog _collectionCatalog;
  final VibeCatalog _vibeCatalog;
  final GenreOfTmdbId _genreOf;

  List<Collection> get _chosenCollections => [
    for (final id in state.collectionIds)
      if (_collectionCatalog.byId(id) case final Collection c) c,
  ];

  /// Step 2's chips: the genres of the kind of title, less what the chosen
  /// collections already require or exclude.
  List<Genre> get vetoOptions =>
      QuizOptions.vetoOptions(state.mediaType, _chosenCollections, _genreOf);

  /// Step 3's chips: the vibes that can still produce something given the
  /// collections and the genres skipped.
  List<Vibe> get vibeOptions => QuizOptions.vibeOptions(
    _vibeCatalog.availableFor(state.mediaType),
    state.mediaType,
    _chosenCollections,
    state.excludedGenres,
    _genreOf,
  );

  /// Emits [next] with what an earlier answer made impossible taken out, in
  /// silence: a skipped genre a collection now requires, a vibe left with no
  /// genre to use.
  void _emitPruned(QuizState next) {
    final type = next.mediaType;
    final collections = [
      for (final id in next.collectionIds)
        if (_collectionCatalog.byId(id) case final Collection c) c,
    ];
    final vetoed = QuizOptions.prunedVetoes(
      next.excludedGenres,
      type,
      collections,
      _genreOf,
    );
    // With no vibe catalog (nothing to check against) the picks stay as they are.
    final vibes = _vibeCatalog.all().isEmpty
        ? next.vibeIds
        : QuizOptions.prunedVibes(
            next.vibeIds,
            _vibeCatalog.availableFor(type),
            type,
            collections,
            vetoed,
            _genreOf,
          );
    emit(next.copyWith(excludedGenres: vetoed, vibeIds: vibes));
  }

  /// Step 1's chip tap — toggles [collectionId], a no-op past
  /// [QuizState.maxCollections].
  void toggleCollection(String collectionId) {
    final current = state.collectionIds;
    if (current.contains(collectionId)) {
      _emitPruned(
        state.copyWith(collectionIds: Set.of(current)..remove(collectionId)),
      );
      return;
    }
    if (current.length >= QuizState.maxCollections) return;
    _emitPruned(state.copyWith(collectionIds: {...current, collectionId}));
  }

  /// Step 2's veto grid tap — toggles [genre]'s chip, a no-op past "up to 3"
  /// chips. On TV, Action & Adventure and Sci-Fi & Fantasy are one chip each:
  /// picking one vetoes every genre it stands for (TMDB excludes a combined TV
  /// genre only when all its members are vetoed), and the cap counts chips.
  void toggleExcludedGenre(Genre genre) {
    final current = state.excludedGenres;
    final members = state.mediaType == MediaType.tvShow
        ? GenreCatalog.tvMembers(genre)
        : {genre};
    if (members.every(current.contains)) {
      _emitPruned(state.copyWith(excludedGenres: current.difference(members)));
      return;
    }
    if (state.excludedChipCount >= QuizState.maxExcludedGenres) return;
    _emitPruned(state.copyWith(excludedGenres: {...current, ...members}));
  }

  /// Step 3's vibe grid tap — toggles [vibeId], a no-op past "exactly 3".
  void toggleVibe(String vibeId) {
    final current = state.vibeIds;
    if (current.contains(vibeId)) {
      emit(state.copyWith(vibeIds: Set.of(current)..remove(vibeId)));
      return;
    }
    if (current.length >= QuizState.maxVibes) return;
    emit(state.copyWith(vibeIds: {...current, vibeId}));
  }

  /// The year slider.
  void setYearFrom(int year) => emit(state.copyWith(yearFrom: year));

  /// The year range's two handles. [to] at or past [currentYear] means "up to
  /// today" and is stored as no upper bound.
  void setYearRange(int from, int to, {required int currentYear}) => emit(
    state.copyWith(yearFrom: from, yearTo: () => to >= currentYear ? null : to),
  );

  /// Tapping a service adds it to the set or takes it out.
  void togglePlatform(int id) {
    final current = state.platformIds;
    emit(
      state.copyWith(
        platformIds: current.contains(id)
            ? (Set.of(current)..remove(id))
            : {...current, id},
      ),
    );
  }

  /// The "All" link: no platform filter.
  void clearPlatforms() => emit(state.copyWith(platformIds: const {}));

  void setIncludeRentBuy(bool value) =>
      emit(state.copyWith(includeRentBuy: value));

  /// Last step, movie sessions only. `null` = "No limit".
  void setMaxRuntimeMinutes(int? minutes) =>
      emit(state.copyWith(maxRuntimeMinutes: () => minutes));

  /// Last step, TV sessions only. `null` = "Either",
  /// [DiscoverTvStatus.ended] = "Finished".
  void setTvStatus(DiscoverTvStatus? status) =>
      emit(state.copyWith(tvStatus: () => status));

  /// Step 4's watched-exclusion toggle, common to both session types.
  void setExcludeWatched(bool value) =>
      emit(state.copyWith(excludeWatched: value));

  /// The "Next" button — a no-op if the current step's own rule isn't
  /// met yet, or if already on the last step (E2's own last step ends in
  /// "Search", not another "Next").
  void nextStep() {
    if (!state.isCurrentStepValid || state.step >= QuizState.stepCount) return;
    emit(state.copyWith(step: state.step + 1));
  }

  /// The back button — never discards anything, just moves [QuizState
  /// .step] back; every field collected so far stays as it was.
  void previousStep() {
    if (state.step <= 1) return;
    emit(state.copyWith(step: state.step - 1));
  }

  /// Step 4's "Search" button. [participantId]/[watchedKeys] aren't
  /// collected by any quiz step — they're session/profile context only
  /// whoever hosts this screen has (a room's own participant id, that
  /// person's own `UserLibraryRepository` watched keys) — parameters
  /// here rather than fields this Cubit would otherwise have to fetch
  /// itself.
  ParticipantAnswers buildAnswers({
    required String participantId,
    Set<MediaKey> watchedKeys = const {},
  }) {
    final s = state;
    return ParticipantAnswers(
      participantId: participantId,
      excludedGenres: s.excludedGenres,
      vibeIds: s.vibeIds,
      yearFrom: s.yearFrom,
      maxRuntimeMinutes: s.mediaType == MediaType.movie
          ? s.maxRuntimeMinutes
          : null,
      tvStatus: s.mediaType == MediaType.tvShow ? s.tvStatus : null,
      excludeWatched: s.excludeWatched,
      watchedKeys: watchedKeys,
      yearTo: s.yearTo,
      platformIds: s.platformIds,
      includeRentBuy: s.includeRentBuy,
      collectionIds: s.collectionIds,
    );
  }
}
