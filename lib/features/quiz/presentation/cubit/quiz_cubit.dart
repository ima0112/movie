import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/discover_filter.dart'
    show DiscoverTvStatus;
import '../../../../core/domain/entities/genre.dart';
import '../../../../core/domain/entities/media_key.dart';
import '../../../../core/domain/entities/media_type.dart';
import '../../../match_engine/domain/participant_answers.dart';
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
  QuizCubit(MediaType mediaType) : super(QuizState(mediaType: mediaType));

  /// Step 1's veto grid tap — toggles [genre], a no-op past "up to 3".
  void toggleExcludedGenre(Genre genre) {
    final current = state.excludedGenres;
    if (current.contains(genre)) {
      emit(state.copyWith(excludedGenres: Set.of(current)..remove(genre)));
      return;
    }
    if (current.length >= QuizState.maxExcludedGenres) return;
    emit(state.copyWith(excludedGenres: {...current, genre}));
  }

  /// Step 2's vibe grid tap — toggles [vibeId], a no-op past "exactly 3".
  void toggleVibe(String vibeId) {
    final current = state.vibeIds;
    if (current.contains(vibeId)) {
      emit(state.copyWith(vibeIds: Set.of(current)..remove(vibeId)));
      return;
    }
    if (current.length >= QuizState.requiredVibeCount) return;
    emit(state.copyWith(vibeIds: {...current, vibeId}));
  }

  /// Step 3's year slider.
  void setYearFrom(int year) => emit(state.copyWith(yearFrom: year));

  /// Step 4, movie sessions only. `null` = "No limit".
  void setMaxRuntimeMinutes(int? minutes) =>
      emit(state.copyWith(maxRuntimeMinutes: () => minutes));

  /// Step 4, TV sessions only. `null` = "Either",
  /// [DiscoverTvStatus.ended] = "Finished".
  void setTvStatus(DiscoverTvStatus? status) =>
      emit(state.copyWith(tvStatus: () => status));

  /// Step 4, TV sessions only. `null` = "No limit".
  void setMaxSeasons(int? seasons) =>
      emit(state.copyWith(maxSeasons: () => seasons));

  /// Step 4's watched-exclusion toggle, common to both session types.
  void setExcludeWatched(bool value) =>
      emit(state.copyWith(excludeWatched: value));

  /// The "Next" button — a no-op if the current step's own rule isn't
  /// met yet, or if already on step 4 (E2's own last step ends in
  /// "Search", not another "Next").
  void nextStep() {
    if (!state.isCurrentStepValid || state.step >= 4) return;
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
      maxSeasons: s.mediaType == MediaType.tvShow ? s.maxSeasons : null,
      excludeWatched: s.excludeWatched,
      watchedKeys: watchedKeys,
    );
  }
}
