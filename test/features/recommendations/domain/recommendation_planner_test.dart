import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/taste_profile.dart';
import 'package:movies/core/domain/entities/user_media_entry.dart';
import 'package:movies/features/match_engine/domain/vibe.dart';
import 'package:movies/features/match_engine/domain/vibe_catalog.dart';
import 'package:movies/features/recommendations/domain/recommendation_planner.dart';

const _action = Genre(id: 'action');
const _drama = Genre(id: 'drama');
const _comedy = Genre(id: 'comedy');
const _horror = Genre(id: 'horror');

UserMediaEntry _entry(
  int id, {
  MediaType type = MediaType.movie,
  bool favorite = false,
  bool later = false,
  int? rating,
  bool watched = false,
  List<Genre> genres = const [],
}) => UserMediaEntry(
  key: MediaKey(type: type, tmdbId: id),
  title: 'Title $id',
  isFavorite: favorite,
  isWatchLater: later,
  watchedAt: watched || rating != null ? DateTime(2026) : null,
  rating: rating,
  genres: genres,
);

TasteProfile _profile({
  Set<Genre> genres = const {},
  Set<String> vibes = const {},
  Set<Genre> vetoed = const {},
}) => TasteProfile(
  likedGenres: genres,
  vetoedGenres: vetoed,
  likedVibes: vibes,
  yearFrom: 1990,
  updatedAt: DateTime(2026),
);

void main() {
  final catalog = VibeCatalog([
    const Vibe(
      id: 'explosive',
      icon: 'vibeExplosive',
      movie: VibeRule(genreIds: ['action'], keywordIds: []),
      tv: VibeRule(genreIds: ['action'], keywordIds: []),
    ),
    const Vibe(
      id: 'classic',
      icon: 'vibeClassic',
      movie: VibeRule(genreIds: ['drama'], keywordIds: []),
      tv: VibeRule(genreIds: ['drama'], keywordIds: []),
      maxReleaseYear: 1999,
      minVoteAverage: 7.5,
    ),
  ]);
  final planner = RecommendationPlanner(catalog);
  final today = DateTime(2026, 5, 4);

  group('seed weight', () {
    test('favorites and well-rated count; watch later is the weakest', () {
      expect(RecommendationPlanner.seedWeight(_entry(1, favorite: true)), 3);
      expect(RecommendationPlanner.seedWeight(_entry(1, rating: 5)), 3);
      expect(RecommendationPlanner.seedWeight(_entry(1, rating: 4)), 2);
      expect(RecommendationPlanner.seedWeight(_entry(1, later: true)), 1);
    });

    test('watched and rated badly, or never rated, never seeds — even if '
        'it is in Watch later', () {
      expect(RecommendationPlanner.seedWeight(_entry(1, rating: 3)), 0);
      expect(
        RecommendationPlanner.seedWeight(_entry(1, rating: 2, later: true)),
        0,
      );
      expect(RecommendationPlanner.seedWeight(_entry(1, watched: true)), 0);
      expect(
        RecommendationPlanner.seedWeight(_entry(1, watched: true, later: true)),
        0,
      );
      expect(RecommendationPlanner.seedWeight(_entry(1)), 0);
    });
  });

  group('Movies / TV Shows follow My List', () {
    test('no usable signal means no sections', () {
      final plan = planner.plan(
        type: MediaType.movie,
        profile: _profile(genres: {_action}), // the profile is ignored here
        library: [
          _entry(1, rating: 2, genres: [_horror]),
        ],
        today: today,
      );
      expect(plan.forYou, isNull);
      expect(plan.becauseLike, isNull);
      expect(plan.becauseWant, isNull);
    });

    test('the seed is a saved title of that type; a different type is '
        'ignored', () {
      final plan = planner.plan(
        type: MediaType.tvShow,
        profile: null,
        library: [
          _entry(1, favorite: true), // a movie
          _entry(2, type: MediaType.tvShow, rating: 5),
        ],
        today: today,
      );
      final seed = plan.becauseLike as TitleSeed;
      expect(seed.entry.key.tmdbId, 2);
    });

    test('For you uses the genres with positive signal and excludes the '
        'ones rated badly', () {
      final plan = planner.plan(
        type: MediaType.movie,
        profile: null,
        library: [
          _entry(1, favorite: true, genres: [_action]),
          _entry(2, rating: 5, genres: [_drama]),
          _entry(3, rating: 1, genres: [_horror]),
        ],
        today: today,
      );
      final filter = plan.forYou!;
      expect(filter.type, MediaType.movie);
      expect(filter.withGenres.difference({_action, _drama}), isEmpty);
      expect(filter.withGenres, isNotEmpty);
      expect(filter.withoutGenres.contains(_horror), isTrue);
    });

    test('the title rotates day to day but is stable within a day', () {
      final library = [for (var i = 1; i <= 6; i++) _entry(i, favorite: true)];
      int seed(DateTime day) =>
          (planner
                      .plan(
                        type: MediaType.movie,
                        profile: null,
                        library: library,
                        today: day,
                      )
                      .becauseLike!
                  as TitleSeed)
              .entry
              .key
              .tmdbId;
      expect(seed(today), seed(DateTime(2026, 5, 4, 20)));
      final seen = {for (var d = 1; d <= 20; d++) seed(DateTime(2026, 5, d))};
      expect(seen.length, greaterThan(2));
    });
  });

  group('All follows the taste profile', () {
    test('no usable profile (or only vetoes) means no sections, whatever '
        'My List holds', () {
      for (final profile in [
        null,
        _profile(vetoed: {_horror}),
      ]) {
        final plan = planner.plan(
          type: null,
          profile: profile,
          library: [
            _entry(1, favorite: true, genres: [_action]),
          ],
          today: today,
        );
        expect(plan.forYou, isNull);
        expect(plan.becauseLike, isNull);
        expect(plan.becauseWant, isNull);
      }
    });

    test('Because you like is a liked genre; Because you want a liked '
        'vibe', () {
      final plan = planner.plan(
        type: null,
        profile: _profile(
          genres: {_action, _drama, _comedy},
          vibes: {'explosive', 'classic'},
          vetoed: {_horror},
        ),
        library: const [],
        today: today,
      );
      expect({
        _action,
        _drama,
        _comedy,
      }, contains((plan.becauseLike as GenreSeed).genre));
      expect(plan.becauseWant!.vibe.id, anyOf('explosive', 'classic'));
      expect(plan.forYou!.withoutGenres, {_horror});
      expect(plan.forYou!.type, isNull);
    });

    test('a profile with only vibes still gives a For you and a want', () {
      final plan = planner.plan(
        type: null,
        profile: _profile(vibes: {'explosive'}),
        library: const [],
        today: today,
      );
      expect(plan.becauseLike, isNull); // no liked genre to name
      expect(plan.becauseWant!.vibe.id, 'explosive');
      expect(plan.forYou!.withGenres, {_action});
    });

    test('the vibe section\'s filter carries the vibe\'s own limits', () {
      final filter = planner.filterForSeed(
        VibeSeed(catalog.byId('classic')!),
        _profile(vetoed: {_horror}),
      );
      expect(filter.yearTo, 1999);
      expect(filter.minVoteAverage, 7.5);
      expect(filter.withGenres, {_drama});
      expect(filter.withoutGenres, {_horror});
    });

    group('the user\'s eras (C5) narrow every profile-based section', () {
      TasteProfile eras({int? to}) => TasteProfile(
        likedGenres: {_action},
        vetoedGenres: const {},
        likedVibes: const {'classic'},
        yearFrom: 1980,
        yearTo: to,
        updatedAt: DateTime(2026),
      );

      test('"For you" carries the range, with no upper bound by default', () {
        final plan = planner.plan(
          type: null,
          profile: eras(),
          library: const [],
          today: today,
        );
        expect(plan.forYou!.yearFrom, 1980);
        expect(plan.forYou!.yearTo, isNull);
      });

      test('a genre section too', () {
        final filter = planner.filterForSeed(
          GenreSeed(_action),
          eras(to: 2010),
        );
        expect(filter.yearFrom, 1980);
        expect(filter.yearTo, 2010);
      });

      test('a vibe section ends at whichever is earlier: the vibe\'s own '
          'ceiling (1999) or the user\'s', () {
        final classic = VibeSeed(catalog.byId('classic')!);
        expect(planner.filterForSeed(classic, eras(to: 2010)).yearTo, 1999);
        expect(planner.filterForSeed(classic, eras(to: 1990)).yearTo, 1990);
        expect(planner.filterForSeed(classic, eras()).yearTo, 1999);
      });
    });
  });
}
