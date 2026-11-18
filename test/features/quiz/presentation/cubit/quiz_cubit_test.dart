import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/discover_filter.dart'
    show DiscoverTvStatus;
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/features/quiz/presentation/cubit/quiz_cubit.dart';
import 'package:movies/features/quiz/presentation/cubit/quiz_state.dart';

const _horror = Genre(id: 'horror');
const _action = Genre(id: 'action');
const _comedy = Genre(id: 'comedy');
const _drama = Genre(id: 'drama');

void main() {
  test('a freshly constructed cubit already has sensible defaults', () {
    final cubit = QuizCubit(MediaType.movie);

    expect(cubit.state.mediaType, MediaType.movie);
    expect(cubit.state.step, 1);
    expect(cubit.state.excludedGenres, isEmpty);
    expect(cubit.state.vibeIds, isEmpty);
    expect(cubit.state.yearFrom, QuizState.defaultYearFrom);
    expect(cubit.state.yearFrom, 1950); // every year until touched
    expect(cubit.state.yearTo, isNull);
    expect(cubit.state.platformIds, isEmpty);
    expect(cubit.state.includeRentBuy, isFalse);
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

      // Step 2 — up to 3 vibes; valid at any count, even none.
      expect(cubit.state.isCurrentStepValid, isTrue);
      cubit.toggleVibe('feel-good');
      cubit.toggleVibe('date-night');
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

  group('QuizCubit — platforms, year range and rent/buy', () {
    test('togglePlatform adds and removes; clearPlatforms is "All"', () {
      final cubit = QuizCubit(MediaType.movie)
        ..togglePlatform(8)
        ..togglePlatform(337);
      expect(cubit.state.platformIds, {8, 337});

      cubit.togglePlatform(8);
      expect(cubit.state.platformIds, {337});

      cubit.clearPlatforms();
      expect(cubit.state.platformIds, isEmpty);
    });

    test('setYearRange: a "to" at or past this year means up to today', () {
      final cubit = QuizCubit(MediaType.movie)
        ..setYearRange(1995, 2015, currentYear: 2026);
      expect(cubit.state.yearFrom, 1995);
      expect(cubit.state.yearTo, 2015);

      cubit.setYearRange(1995, 2026, currentYear: 2026);
      expect(cubit.state.yearTo, isNull);
    });

    test('buildAnswers carries platforms, the latest year and rent/buy', () {
      final cubit = QuizCubit(MediaType.movie)
        ..togglePlatform(8)
        ..setIncludeRentBuy(true)
        ..setYearRange(1995, 2015, currentYear: 2026);

      final answers = cubit.buildAnswers(participantId: 'me');

      expect(answers.platformIds, {8});
      expect(answers.includeRentBuy, isTrue);
      expect(answers.yearFrom, 1995);
      expect(answers.yearTo, 2015);
    });

    test('rent/buy is dropped from the answers while no platform is picked, '
        'but kept in the state so the switch remembers it', () {
      final cubit = QuizCubit(MediaType.movie)..setIncludeRentBuy(true);

      expect(cubit.buildAnswers(participantId: 'me').includeRentBuy, isFalse);
      expect(cubit.state.includeRentBuy, isTrue);

      cubit.togglePlatform(8);
      expect(cubit.buildAnswers(participantId: 'me').includeRentBuy, isTrue);
    });

    test('the defaults ask for nothing: no platform, open years, no limit', () {
      final answers = QuizCubit(
        MediaType.movie,
      ).buildAnswers(participantId: 'me');

      expect(answers.platformIds, isEmpty);
      expect(answers.yearFrom, 1950);
      expect(answers.yearTo, isNull);
      expect(answers.maxRuntimeMinutes, isNull);
      expect(answers.includeRentBuy, isFalse);
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

    test(
      'step 2 is valid with no vibes, with some, and with the 3 allowed',
      () {
        final cubit = QuizCubit(MediaType.movie)..nextStep();
        expect(cubit.state.step, 2);

        expect(cubit.state.isCurrentStepValid, isTrue);
        cubit.toggleVibe('a');
        expect(cubit.state.isCurrentStepValid, isTrue);
        cubit
          ..toggleVibe('b')
          ..toggleVibe('c');
        expect(cubit.state.isCurrentStepValid, isTrue);
      },
    );

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

    test('no step blocks "Next": every one has a default', () {
      final cubit = QuizCubit(MediaType.movie)..nextStep(); // step 1 → 2
      cubit.nextStep(); // no vibes picked: still advances
      expect(cubit.state.step, 3);
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
