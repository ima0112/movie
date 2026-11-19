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

      // Step 1 — collections: optional, up to 2; "Continue" is on from the
      // start.
      expect(cubit.state.isCurrentStepValid, isTrue);
      cubit.nextStep();
      expect(cubit.state.step, 2);

      // Step 2 — 1 to 3 excluded genres; "Continue" waits for the first.
      expect(cubit.state.isCurrentStepValid, isFalse);
      cubit.toggleExcludedGenre(_horror);
      expect(cubit.state.isCurrentStepValid, isTrue);
      cubit.toggleExcludedGenre(_action);
      cubit.nextStep();
      expect(cubit.state.step, 3);

      // Step 3 — 1 to 3 vibes; "Continue" waits for the first.
      expect(cubit.state.isCurrentStepValid, isFalse);
      cubit.toggleVibe('feel-good');
      cubit.toggleVibe('date-night');
      cubit.toggleVibe('cozy');
      expect(cubit.state.isCurrentStepValid, isTrue);
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
    test('step 2 needs at least one veto, and takes up to 3', () {
      final cubit = QuizCubit(MediaType.movie)..nextStep();
      expect(cubit.state.isCurrentStepValid, isFalse);

      cubit.toggleExcludedGenre(_horror);
      expect(cubit.state.isCurrentStepValid, isTrue);
      cubit
        ..toggleExcludedGenre(_action)
        ..toggleExcludedGenre(_comedy);
      expect(cubit.state.isCurrentStepValid, isTrue);

      // Taking the last ones back out blocks it again.
      cubit
        ..toggleExcludedGenre(_horror)
        ..toggleExcludedGenre(_action)
        ..toggleExcludedGenre(_comedy);
      expect(cubit.state.isCurrentStepValid, isFalse);
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

    test('step 3 needs at least one vibe, and takes up to 3', () {
      final cubit = QuizCubit(MediaType.movie)
        ..nextStep()
        ..toggleExcludedGenre(_horror)
        ..nextStep();
      expect(cubit.state.step, 3);

      expect(cubit.state.isCurrentStepValid, isFalse);
      cubit.toggleVibe('a');
      expect(cubit.state.isCurrentStepValid, isTrue);
      cubit
        ..toggleVibe('b')
        ..toggleVibe('c');
      expect(cubit.state.isCurrentStepValid, isTrue);

      cubit
        ..toggleVibe('a')
        ..toggleVibe('b')
        ..toggleVibe('c');
      expect(cubit.state.isCurrentStepValid, isFalse);
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

    test('nextStep() is a no-op on the genre and vibe steps until something is '
        'picked', () {
      final cubit = QuizCubit(MediaType.movie)..nextStep(); // collections
      expect(cubit.state.step, 2);
      cubit.nextStep(); // nothing vetoed
      expect(cubit.state.step, 2);

      cubit
        ..toggleExcludedGenre(_horror)
        ..nextStep();
      expect(cubit.state.step, 3);

      cubit.nextStep(); // no vibe yet
      expect(cubit.state.step, 3);

      cubit
        ..toggleVibe('a')
        ..nextStep();
      expect(cubit.state.step, 4);
    });

    test('the collections, platforms and years steps never block', () {
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
      final cubit = QuizCubit(MediaType.movie)
        ..toggleExcludedGenre(_horror)
        ..toggleVibe('a');
      for (var i = 0; i < 8; i++) {
        cubit.nextStep();
      }
      expect(cubit.state.step, QuizState.stepCount);
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

  group('QuizCubit — collections', () {
    final catalog = CollectionCatalog.fromJsonString(
      File('assets/collections.json').readAsStringSync(),
    );
    final vibes = VibeCatalog.fromJsonString(
      File('assets/vibes.json').readAsStringSync(),
    );
    QuizCubit build(MediaType type) =>
        QuizCubit(type, collectionCatalog: catalog, vibeCatalog: vibes);

    test('up to two; a third is ignored; taking one out frees it', () {
      final cubit = build(MediaType.tvShow)
        ..toggleCollection('turkish_series')
        ..toggleCollection('anime')
        ..toggleCollection('soaps');
      expect(cubit.state.collectionIds, {'turkish_series', 'anime'});

      cubit
        ..toggleCollection('anime')
        ..toggleCollection('soaps');
      expect(cubit.state.collectionIds, {'turkish_series', 'soaps'});
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
