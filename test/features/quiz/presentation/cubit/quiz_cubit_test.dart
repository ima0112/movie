import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/collection_catalog.dart';
import 'package:movies/features/match_engine/domain/vibe_catalog.dart';
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
    expect(cubit.state.excludeWatched, isFalse);
  });

  group('QuizCubit — a movie session walking all 5 steps', () {
    test('produces the correct ParticipantAnswers at the end', () {
      final cubit = QuizCubit(MediaType.movie);

      // Step 1 — collections: optional, up to 2.
      cubit.nextStep();
      expect(cubit.state.step, 2);

      // Step 2 — up to 3 excluded genres.
      cubit.toggleExcludedGenre(_horror);
      cubit.toggleExcludedGenre(_action);
      cubit.nextStep();
      expect(cubit.state.step, 3);

      // Step 3 — up to 3 vibes.
      cubit.toggleVibe('feel-good');
      cubit.toggleVibe('date-night');
      cubit.toggleVibe('cozy');
      cubit.nextStep();
      expect(cubit.state.step, 4);

      // Step 4 — platforms (defaults).
      cubit.nextStep();
      expect(cubit.state.step, 5);

      // Step 5 — how far back; movie branch: max runtime + the watched toggle.
      cubit.setYearFrom(2005);
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

    test('rent/buy goes to the engine whether platforms are picked or not '
        '("All platforms" covers the whole region)', () {
      final cubit = QuizCubit(MediaType.movie)..setIncludeRentBuy(true);

      final all = cubit.buildAnswers(participantId: 'me');
      expect(all.platformIds, isEmpty);
      expect(all.includeRentBuy, isTrue);

      cubit.togglePlatform(8);
      expect(cubit.buildAnswers(participantId: 'me').includeRentBuy, isTrue);

      cubit.setIncludeRentBuy(false);
      expect(cubit.buildAnswers(participantId: 'me').includeRentBuy, isFalse);
    });

    test('"All platforms" is simply no platform picked: picking one leaves it, '
        'taking the last out brings it back', () {
      final cubit = QuizCubit(MediaType.movie);
      expect(cubit.state.platformIds, isEmpty);

      cubit.togglePlatform(8);
      expect(cubit.state.platformIds, isNotEmpty);

      cubit.togglePlatform(8);
      expect(cubit.state.platformIds, isEmpty);
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
    test('buildAnswers fills tvStatus, never maxRuntimeMinutes', () {
      final cubit = QuizCubit(MediaType.tvShow)
        ..toggleVibe('superhero')
        ..toggleVibe('gritty')
        ..toggleVibe('tearjerker')
        ..setTvStatus(DiscoverTvStatus.ended)
        // Set on a TV session anyway — buildAnswers must still drop it,
        // not just happen to leave it null because nobody called this.
        ..setMaxRuntimeMinutes(120);

      final answers = cubit.buildAnswers(participantId: 'ana');

      expect(answers.tvStatus, DiscoverTvStatus.ended);
      expect(answers.maxSeasons, isNull); // no longer asked
      expect(answers.maxRuntimeMinutes, isNull);
    });
  });

  group('QuizCubit — step validation and the "Next" button', () {
    test('every step is optional: Continue never blocks, and the genre step '
        'takes up to 3', () {
      final cubit = QuizCubit(MediaType.movie);
      for (var i = 0; i < 4; i++) {
        expect(cubit.state.isCurrentStepValid, isTrue);
        cubit.nextStep();
      }
      expect(cubit.state.step, 5); // nothing picked anywhere

      final genres = QuizCubit(MediaType.movie)
        ..toggleExcludedGenre(_horror)
        ..toggleExcludedGenre(_action)
        ..toggleExcludedGenre(_comedy)
        ..toggleExcludedGenre(_drama);
      expect(genres.state.excludedGenres, {_horror, _action, _comedy});
    });

    test('on TV a combined chip vetoes all its genres and counts as one', () {
      final cubit = QuizCubit(MediaType.tvShow)
        ..toggleExcludedGenre(_action)
        ..toggleExcludedGenre(const Genre(id: 'sci-fi'));
      expect(cubit.state.excludedGenres, {
        _action,
        const Genre(id: 'adventure'),
        const Genre(id: 'sci-fi'),
        const Genre(id: 'fantasy'),
      });
      expect(cubit.state.excludedChipCount, 2);

      cubit
        ..toggleExcludedGenre(_comedy)
        ..toggleExcludedGenre(_drama); // a 4th chip: ignored
      expect(cubit.state.excludedChipCount, 3);
      expect(cubit.state.excludedGenres, isNot(contains(_drama)));

      cubit.toggleExcludedGenre(_action); // takes the whole chip back out
      expect(cubit.state.excludedGenres, isNot(contains(_action)));
      expect(
        cubit.state.excludedGenres,
        isNot(contains(const Genre(id: 'adventure'))),
      );
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

    test('a search can go through with nothing picked at all', () {
      final cubit = QuizCubit(MediaType.movie);
      expect(cubit.state.isCurrentStepValid, isTrue);
      cubit
        ..nextStep()
        ..toggleExcludedGenre(_horror)
        ..nextStep()
        ..toggleVibe('a')
        ..nextStep();
      expect(cubit.state.step, 4);
      expect(cubit.state.isCurrentStepValid, isTrue);

      cubit.nextStep();
      expect(cubit.state.step, 5);
      expect(cubit.state.isCurrentStepValid, isTrue);
    });

    test('nextStep() does nothing past the last step', () {
      final cubit = QuizCubit(MediaType.movie);
      for (var i = 0; i < 8; i++) {
        cubit.nextStep();
      }
      expect(cubit.state.step, QuizState.stepCount);
    });

    test('previousStep() does nothing before step 1', () {
      final cubit = QuizCubit(MediaType.movie)..previousStep();
      expect(cubit.state.step, 1);
    });

    test('going back clears what the step you leave had collected, and '
        'keeps the earlier steps\' answers', () {
      final cubit = QuizCubit(MediaType.movie)
        ..toggleCollection('anime')
        ..nextStep() // → 2
        ..toggleExcludedGenre(_horror)
        ..nextStep() // → 3
        ..toggleVibe('a')
        ..nextStep() // → 4
        ..togglePlatform(8)
        ..setIncludeRentBuy(true)
        ..nextStep() // → 5
        ..setYearRange(1990, 2010, currentYear: 2026)
        ..setMaxRuntimeMinutes(120)
        ..setExcludeWatched(true);

      cubit.previousStep(); // 5 → 4: the years and limits go
      expect(cubit.state.step, 4);
      expect(cubit.state.yearFrom, QuizState.defaultYearFrom);
      expect(cubit.state.yearTo, isNull);
      expect(cubit.state.maxRuntimeMinutes, isNull);
      expect(cubit.state.excludeWatched, isFalse);
      expect(cubit.state.platformIds, {8});

      cubit.previousStep(); // 4 → 3: the platforms go
      expect(cubit.state.platformIds, isEmpty);
      expect(cubit.state.includeRentBuy, isFalse);
      expect(cubit.state.vibeIds, {'a'});

      cubit.previousStep(); // 3 → 2: the vibes go
      expect(cubit.state.vibeIds, isEmpty);
      expect(cubit.state.excludedGenres, {_horror});

      cubit.previousStep(); // 2 → 1: the genres go
      expect(cubit.state.excludedGenres, isEmpty);
      expect(cubit.state.collectionIds, {'anime'});
    });
  });

  group('QuizCubit — collections', () {
    final catalog = CollectionCatalog.fromJsonString(
      File('assets/collections.json').readAsStringSync(),
    );
    final vibes = VibeCatalog.fromJsonString(
      File('assets/vibes.json').readAsStringSync(),
    );
    QuizCubit build(MediaType type) =>
        QuizCubit(type, collectionCatalog: catalog, vibeCatalog: vibes);

    test('one at most: picking another replaces it, picking the same one '
        'clears it', () {
      final cubit = build(MediaType.tvShow)..toggleCollection('turkish_series');
      expect(cubit.state.collectionIds, {'turkish_series'});

      cubit.toggleCollection('anime');
      expect(cubit.state.collectionIds, {'anime'});

      cubit.toggleCollection('anime');
      expect(cubit.state.collectionIds, isEmpty);
    });

    test('they reach the answers', () {
      final cubit = build(MediaType.tvShow)..toggleCollection('k_dramas');
      expect(cubit.buildAnswers(participantId: 'me').collectionIds, {
        'k_dramas',
      });
    });

    test('Kids on movies takes Family, Animation, Horror, Thriller and Crime '
        'out of the veto list', () {
      final cubit = build(MediaType.movie);
      expect(cubit.vetoOptions, hasLength(18));
      cubit.toggleCollection('kids');
      expect(cubit.vetoOptions, hasLength(13));
    });

    test('choosing a collection silently drops a veto and a vibe it makes '
        'impossible', () {
      final cubit = build(MediaType.movie)
        ..toggleExcludedGenre(_horror)
        ..toggleExcludedGenre(_comedy)
        ..toggleVibe('gritty')
        ..toggleVibe('superhero');

      cubit.toggleCollection('kids');

      expect(cubit.state.excludedGenres, {_comedy}); // Horror is excluded
      expect(cubit.state.vibeIds, {'superhero'}); // Gritty has no genre left
    });

    test('vetoing every genre of an ambiente drops it from the picks', () {
      final cubit = build(MediaType.movie)
        ..toggleVibe('feel_good')
        ..toggleExcludedGenre(_comedy)
        ..toggleExcludedGenre(const Genre(id: 'family'));
      expect(cubit.state.vibeIds, isEmpty);
    });
  });
}
