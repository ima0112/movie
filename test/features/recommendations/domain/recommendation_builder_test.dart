import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/taste_profile.dart';
import 'package:movies/core/domain/entities/user_media_entry.dart';
import 'package:movies/features/match_engine/domain/vibe.dart';
import 'package:movies/features/match_engine/domain/vibe_catalog.dart';
import 'package:movies/features/recommendations/domain/recommendation_builder.dart';

const _action = Genre(id: 'action');
const _drama = Genre(id: 'drama');
const _comedy = Genre(id: 'comedy');

const _dune = MediaKey(type: MediaType.movie, tmdbId: 1);
const _bear = MediaKey(type: MediaType.tvShow, tmdbId: 101);
const _boys = MediaKey(type: MediaType.tvShow, tmdbId: 106);

Movie _movie(int id, {Genre? genre, String? posterUrl = 'poster'}) => Movie(
  id: id,
  title: 'Movie $id',
  posterUrl: posterUrl,
  genres: genre == null ? const [] : [genre],
  releaseDate: null,
  voteAverage: 7,
);

void main() {
  final catalog = VibeCatalog([
    Vibe(
      id: 'explosive',
      icon: 'vibeExplosive',
      movie: const VibeRule(genreIds: ['action'], keywordIds: []),
      tv: const VibeRule(genreIds: ['action'], keywordIds: []),
    ),
    Vibe(
      id: 'monster',
      icon: 'vibeMonster',
      movie: const VibeRule(genreIds: [], keywordIds: ['1299']),
      tv: const VibeRule(genreIds: [], keywordIds: ['1299']),
    ),
  ]);
  final builder = RecommendationBuilder(catalog);

  group('RecommendationBuilder.forYouFilter', () {
    test('a usable profile builds a filter from its liked genres + '
        'vibes\' own genre/keyword rules, vetoes as withoutGenres', () {
      final filter = builder.forYouFilter(
        profile: TasteProfile(
          likedGenres: {_drama},
          vetoedGenres: {_comedy},
          likedVibes: {'explosive', 'monster'},
          yearFrom: 1990,
          updatedAt: DateTime(2024),
        ),
        libraryEntries: const [],
        type: MediaType.movie,
      );

      expect(filter, isNotNull);
      expect(filter!.withGenres, {_drama, _action});
      expect(filter.withKeywords, {1299});
      expect(filter.withoutGenres, {_comedy});
      expect(filter.type, MediaType.movie);
    });

    test('type: null (segment "All") is passed straight through — no '
        'special-casing, MediaRepository.discover already interleaves', () {
      final filter = builder.forYouFilter(
        profile: TasteProfile(
          likedGenres: {_drama},
          vetoedGenres: const {},
          likedVibes: const {},
          yearFrom: 1990,
          updatedAt: DateTime(2024),
        ),
        libraryEntries: const [],
        type: null,
      );

      expect(filter!.type, isNull);
    });

    test('no usable profile falls back to the library signal — genres '
        'with positive affinity among favorites/well-rated watches', () {
      final filter = builder.forYouFilter(
        profile: null,
        libraryEntries: [
          const UserMediaEntry(
            key: _dune,
            title: 'Dune',
            isFavorite: true,
            genres: [_action],
          ),
          UserMediaEntry(
            key: _bear,
            title: 'The Bear',
            watchedAt: DateTime(2024),
            rating: 5,
            genres: const [_drama],
          ),
          UserMediaEntry(
            key: _boys,
            title: 'The Boys',
            watchedAt: DateTime(2024),
            rating: 1,
            genres: const [_comedy],
          ),
        ],
        type: null,
      );

      expect(filter!.withGenres, {_action, _drama});
      expect(filter.withKeywords, isEmpty);
      // The penalized genre (rating 1) never appears as a positive signal.
      expect(filter.withGenres.contains(_comedy), isFalse);
    });

    test('no usable profile and no library signal at all -> null, not an '
        'empty or generic filter', () {
      final filter = builder.forYouFilter(
        profile: null,
        libraryEntries: const [],
        type: null,
      );

      expect(filter, isNull);
    });

    test('a profile with only vetoes/yearFrom touched (not '
        'isUsableForSuggestions) falls through to the library case '
        'exactly like no profile at all', () {
      final filter = builder.forYouFilter(
        profile: TasteProfile(
          likedGenres: const {},
          vetoedGenres: {_comedy},
          likedVibes: const {},
          yearFrom: 2010,
          updatedAt: DateTime(2024),
        ),
        libraryEntries: [
          const UserMediaEntry(
            key: _dune,
            title: 'Dune',
            isFavorite: true,
            genres: [_action],
          ),
        ],
        type: null,
      );

      expect(filter!.withGenres, {_action});
    });
  });

  group('RecommendationBuilder.becauseYouLikeSeed', () {
    test('picks the highest-rated entry; a rating of 5 beats a favorite '
        'with no rating at all', () {
      final seed = builder.becauseYouLikeSeed(
        libraryEntries: [
          const UserMediaEntry(key: _dune, title: 'Dune', isFavorite: true),
          UserMediaEntry(
            key: _bear,
            title: 'The Bear',
            rating: 5,
            watchedAt: DateTime(2023),
          ),
        ],
        type: null,
      );

      expect(seed!.key, _bear);
    });

    test('a tied rating is broken by the most recently watched', () {
      final seed = builder.becauseYouLikeSeed(
        libraryEntries: [
          UserMediaEntry(
            key: _dune,
            title: 'Dune',
            rating: 5,
            watchedAt: DateTime(2023, 1, 1),
          ),
          UserMediaEntry(
            key: _bear,
            title: 'The Bear',
            rating: 5,
            watchedAt: DateTime(2024, 1, 1),
          ),
        ],
        type: null,
      );

      expect(seed!.key, _bear);
    });

    test('a tie with no watchedAt at all is broken by tmdbId — fully '
        'deterministic, no randomness', () {
      final seedA = builder.becauseYouLikeSeed(
        libraryEntries: [
          const UserMediaEntry(key: _dune, title: 'Dune', isFavorite: true),
          const UserMediaEntry(key: _bear, title: 'The Bear', isFavorite: true),
        ],
        type: null,
      );
      final seedB = builder.becauseYouLikeSeed(
        libraryEntries: [
          const UserMediaEntry(key: _bear, title: 'The Bear', isFavorite: true),
          const UserMediaEntry(key: _dune, title: 'Dune', isFavorite: true),
        ],
        type: null,
      );

      // Same winner regardless of input order — a stable, deterministic
      // criterion, not whatever order the list happened to arrive in.
      expect(seedA!.key, seedB!.key);
    });

    test('type filters candidates to the current segment', () {
      final seed = builder.becauseYouLikeSeed(
        libraryEntries: [
          const UserMediaEntry(key: _dune, title: 'Dune', isFavorite: true),
          const UserMediaEntry(key: _bear, title: 'The Bear', isFavorite: true),
        ],
        type: MediaType.tvShow,
      );

      expect(seed!.key, _bear);
    });

    test('no favorite and nothing rated >= 4 -> null, hide the section', () {
      final seed = builder.becauseYouLikeSeed(
        libraryEntries: [
          const UserMediaEntry(key: _dune, title: 'Dune', rating: 3),
        ],
        type: null,
      );

      expect(seed, isNull);
    });
  });

  group('RecommendationBuilder.excludeLibraryItems', () {
    test('drops anything whose key is already in the library, keeps the '
        'rest in the same order', () {
      final result = builder.excludeLibraryItems(
        [_movie(1), _movie(2), _movie(3)],
        {const MediaKey(type: MediaType.movie, tmdbId: 2)},
      );

      expect(result.map((m) => m.id), [1, 3]);
    });
  });

  group('RecommendationBuilder.filterAndThreshold', () {
    test('drops posterless items and library items before counting '
        'toward the minimum', () {
      final result = builder.filterAndThreshold(
        List.generate(
          RecommendationBuilder.minRecommendationCount + 2,
          (i) => _movie(i),
        )..add(_movie(999, posterUrl: null)),
        {const MediaKey(type: MediaType.movie, tmdbId: 0)},
      );

      expect(result, isNotNull);
      expect(result, isNot(contains(isA<Movie>().having((m) => m.id, 'id', 0))));
      expect(result!.every((m) => m.posterUrl != null), isTrue);
    });

    test('fewer than minRecommendationCount after filtering -> null, no '
        'half-empty carousel', () {
      final result = builder.filterAndThreshold(
        List.generate(RecommendationBuilder.minRecommendationCount - 1, _movie),
        const {},
      );

      expect(result, isNull);
    });

    test('exactly minRecommendationCount survives', () {
      final result = builder.filterAndThreshold(
        List.generate(RecommendationBuilder.minRecommendationCount, _movie),
        const {},
      );

      expect(result, hasLength(RecommendationBuilder.minRecommendationCount));
    });
  });
}
