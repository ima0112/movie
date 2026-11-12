import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/features/recommendations/domain/recommendation_builder.dart';

Movie _movie(int id, {Genre? genre, String? posterUrl = 'poster'}) => Movie(
  id: id,
  title: 'Movie $id',
  posterUrl: posterUrl,
  genres: genre == null ? const [] : [genre],
  releaseDate: null,
  voteAverage: 7,
);

void main() {
  const builder = RecommendationBuilder();

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
      expect(
        result,
        isNot(contains(isA<Movie>().having((m) => m.id, 'id', 0))),
      );
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
