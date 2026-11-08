import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_detail.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/features/discover/data/repositories/fake_media_repository.dart';

void main() {
  group('FakeMediaRepository.detail', () {
    final repository = FakeMediaRepository();

    test(
      'returns a coherent MovieDetail for each of the 3 sample ids',
      () async {
        for (final id in [1, 2, 3]) {
          final result = await repository.detail(
            MediaKey(type: MediaType.movie, tmdbId: id),
          );

          expect(result, isA<Success<MediaDetail>>());
          final detail = (result as Success<MediaDetail>).value as MovieDetail;

          expect(detail.item.id, id);
          expect(detail.overview, isNotEmpty);
          expect(detail.cast, isNotEmpty);
          expect(detail.crew, isNotEmpty);
          expect(
            detail.trailer,
            isNotNull,
            reason: 'D1 needs a Trailer button',
          );
          expect(detail.trailer!.isYoutube, isTrue);
          expect(detail.similar, isNotEmpty);
          expect(detail.watchProviders.hasAny, isTrue);
          expect(detail.runtimeMinutes, isNotNull);
        }
      },
    );

    test(
      'falls back to an empty-but-valid detail for a movie with no sample data',
      () async {
        final result = await repository.detail(
          const MediaKey(type: MediaType.movie, tmdbId: 4), // Knives Out
        );

        final detail = (result as Success<MediaDetail>).value as MovieDetail;

        expect(detail.item.title, 'Knives Out');
        expect(detail.cast, isEmpty);
        expect(detail.trailer, isNull);
        expect(detail.watchProviders.hasAny, isFalse);
      },
    );

    test('fails for an unknown movie id', () async {
      final result = await repository.detail(
        const MediaKey(type: MediaType.movie, tmdbId: 999),
      );

      expect(result, isA<Failure<MediaDetail>>());
    });

    test('fails for a TV show key (D2 not implemented yet)', () async {
      final result = await repository.detail(
        const MediaKey(type: MediaType.tvShow, tmdbId: 101),
      );

      expect(result, isA<Failure<MediaDetail>>());
    });
  });
}
