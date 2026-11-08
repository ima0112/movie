import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/discover_filter.dart'
    show DiscoverTvStatus;
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/features/quiz/presentation/cubit/quiz_cubit.dart';
import 'package:movies/features/quiz/presentation/cubit/quiz_state.dart';

const _horror = Genre(id: 'horror', name: 'Horror');
const _action = Genre(id: 'action', name: 'Action');
const _comedy = Genre(id: 'comedy', name: 'Comedy');
const _drama = Genre(id: 'drama', name: 'Drama');

void main() {
  test('a freshly constructed cubit already has sensible defaults', () {
    final cubit = QuizCubit(MediaType.movie);

    expect(cubit.state.mediaType, MediaType.movie);
    expect(cubit.state.step, 1);
    expect(cubit.state.excludedGenres, isEmpty);
    expect(cubit.state.vibeIds, isEmpty);
    expect(cubit.state.yearFrom, QuizState.defaultYearFrom);
    expect(cubit.state.maxRuntimeMinutes, isNull);
    expect(cubit.state.tvStatus, isNull);
    expect(cubit.state.maxSeasons, isNull);
    expect(cubit.state.excludeWatched, isFalse);
  });

  group('QuizCubit — a movie session walking all 4 steps', () {
    test('produces the correct ParticipantAnswers at the end', () {
      final cubit = QuizCubit(MediaType.movie);

      // Step 1 — up to 3 excluded genres; valid even before touching it.
      expect(cubit.state.isCurrentStepValid, isTrue);
      cubit.toggleExcludedGenre(_horror);
      cubit.toggleExcludedGenre(_action);
      cubit.nextStep();
      expect(cubit.state.step, 2);

      // Step 2 — exactly 3 vibes.
      expect(cubit.state.isCurrentStepValid, isFalse);
      cubit.toggleVibe('feel-good');
      cubit.toggleVibe('date-night');
      expect(cubit.state.isCurrentStepValid, isFalse);
      cubit.toggleVibe('cozy');
      expect(cubit.state.isCurrentStepValid, isTrue);
      cubit.nextStep();
      expect(cubit.state.step, 3);

      // Step 3 — how far back.
      cubit.setYearFrom(2005);
      cubit.nextStep();
      expect(cubit.state.step, 4);

      // Step 4 — movie branch: max runtime + the watched toggle.
      cubit.setMaxRuntimeMinutes(150);
      cubit.setExcludeWatched(true);

      const dune = MediaKey(type: MediaType.movie, tmdbId: 1);
      final answers = cubit.buildAnswers(
        participantId: 'daniel',
        watchedKeys: {dune},
      );

      expect(answers.participantId, 'daniel');
      expect(answers.excludedGenres, {_horror, _action});
      expect(answers.vibeIds, {'feel-good', 'date-night', 'cozy'});
      expect(answers.yearFrom, 2005);
      expect(answers.maxRuntimeMinutes, 150);
      expect(answers.tvStatus, isNull);
      expect(answers.maxSeasons, isNull);
      expect(answers.excludeWatched, isTrue);
      expect(answers.watchedKeys, {dune});
    });
  });

  group('QuizCubit — a TV session', () {
    test('buildAnswers fills tvStatus/maxSeasons, never '
        'maxRuntimeMinutes', () {
      final cubit = QuizCubit(MediaType.tvShow)
        ..toggleVibe('superhero')
        ..toggleVibe('gritty')
        ..toggleVibe('tearjerker')
        ..setTvStatus(DiscoverTvStatus.ended)
        ..setMaxSeasons(5)
        // Set on a TV session anyway — buildAnswers must still drop it,
        // not just happen to leave it null because nobody called this.
        ..setMaxRuntimeMinutes(120);

      final answers = cubit.buildAnswers(participantId: 'ana');

      expect(answers.tvStatus, DiscoverTvStatus.ended);
      expect(answers.maxSeasons, 5);
      expect(answers.maxRuntimeMinutes, isNull);
    });
  });

  group('QuizCubit — step validation and the "Next" button', () {
    test('step 1 is always valid, even with 0 vetoes', () {
      expect(QuizCubit(MediaType.movie).state.isCurrentStepValid, isTrue);
    });

    test('step 2 is invalid below 3 vibes, valid at exactly 3', () {
      final cubit = QuizCubit(MediaType.movie)..nextStep();
      expect(cubit.state.step, 2);

      expect(cubit.state.isCurrentStepValid, isFalse);
      cubit.toggleVibe('a');
      expect(cubit.state.isCurrentStepValid, isFalse);
      cubit.toggleVibe('b');
      expect(cubit.state.isCurrentStepValid, isFalse);
      cubit.toggleVibe('c');
      expect(cubit.state.isCurrentStepValid, isTrue);
    });

    test('a 4th vibe is ignored once 3 are already selected', () {
      final cubit = QuizCubit(MediaType.movie)
        ..toggleVibe('a')
        ..toggleVibe('b')
        ..toggleVibe('c')
        ..toggleVibe('d');

      expect(cubit.state.vibeIds, {'a', 'b', 'c'});
    });

    test('a 4th excluded genre is ignored once 3 are already selected', () {
      final cubit = QuizCubit(MediaType.movie)
        ..toggleExcludedGenre(_horror)
        ..toggleExcludedGenre(_action)
        ..toggleExcludedGenre(_comedy)
        ..toggleExcludedGenre(_drama);

      expect(cubit.state.excludedGenres, {_horror, _action, _comedy});
    });

    test('toggling an already-selected genre/vibe removes it, and does '
        "not count against the cap", () {
      final cubit = QuizCubit(MediaType.movie)
        ..toggleExcludedGenre(_horror)
        ..toggleExcludedGenre(_horror);
      expect(cubit.state.excludedGenres, isEmpty);
    });

    test('nextStep() is a no-op while the current step is invalid', () {
      final cubit = QuizCubit(MediaType.movie)
        ..nextStep(); // step 1 → 2
      cubit.nextStep(); // step 2 is invalid (0 vibes) — should not advance
      expect(cubit.state.step, 2);
    });

    test('nextStep() does nothing past step 4', () {
      final cubit = QuizCubit(MediaType.movie)
        ..toggleVibe('a')
        ..toggleVibe('b')
        ..toggleVibe('c');
      cubit.nextStep(); // 1 → 2
      cubit.nextStep(); // 2 → 3
      cubit.nextStep(); // 3 → 4
      cubit.nextStep(); // stays at 4
      expect(cubit.state.step, 4);
    });

    test('previousStep() does nothing before step 1', () {
      final cubit = QuizCubit(MediaType.movie)..previousStep();
      expect(cubit.state.step, 1);
    });

    test('previousStep() preserves earlier answers — the back button '
        'never discards anything', () {
      final cubit = QuizCubit(MediaType.movie)
        ..toggleExcludedGenre(_horror)
        ..nextStep(); // → step 2
      cubit.previousStep(); // → step 1

      expect(cubit.state.step, 1);
      expect(cubit.state.excludedGenres, {_horror});
    });
  });
}
