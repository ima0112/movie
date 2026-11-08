import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/tmdb/tmdb_image_urls.dart';

void main() {
  const config = TmdbImagesConfig(
    secureBaseUrl: 'https://image.tmdb.org/t/p/',
    posterSizes: ['w92', 'w342', 'original'],
    backdropSizes: ['w780', 'original'],
    profileSizes: ['w185', 'original'],
  );

  group('buildTmdbImageUrl', () {
    test('null path -> null (no image for this item)', () {
      final url = buildTmdbImageUrl(
        config: config,
        kind: TmdbImageKind.poster,
        path: null,
        size: 'w342',
      );

      expect(url, isNull);
    });

    test('builds secureBaseUrl + size + path', () {
      final url = buildTmdbImageUrl(
        config: config,
        kind: TmdbImageKind.poster,
        path: '/abc123.jpg',
        size: 'w342',
      );

      expect(url, 'https://image.tmdb.org/t/p/w342/abc123.jpg');
    });

    test('a size not in this kind\'s list falls back to "original"', () {
      final url = buildTmdbImageUrl(
        config: config,
        kind: TmdbImageKind.poster,
        path: '/abc123.jpg',
        size: 'w9999',
      );

      expect(url, 'https://image.tmdb.org/t/p/original/abc123.jpg');
    });

    test('validates size against the requested kind, not any kind', () {
      // w780 is a valid *backdrop* size but not a poster size here.
      final url = buildTmdbImageUrl(
        config: config,
        kind: TmdbImageKind.poster,
        path: '/abc123.jpg',
        size: 'w780',
      );

      expect(url, 'https://image.tmdb.org/t/p/original/abc123.jpg');
    });

    test('backdrop and profile kinds validate against their own lists', () {
      expect(
        buildTmdbImageUrl(
          config: config,
          kind: TmdbImageKind.backdrop,
          path: '/b.jpg',
          size: 'w780',
        ),
        'https://image.tmdb.org/t/p/w780/b.jpg',
      );
      expect(
        buildTmdbImageUrl(
          config: config,
          kind: TmdbImageKind.profile,
          path: '/p.jpg',
          size: 'w185',
        ),
        'https://image.tmdb.org/t/p/w185/p.jpg',
      );
    });
  });

  group('TmdbImagesConfig.fallback', () {
    test('has TMDB\'s well-known stable defaults', () {
      const fallback = TmdbImagesConfig.fallback();

      expect(fallback.secureBaseUrl, 'https://image.tmdb.org/t/p/');
      expect(fallback.posterSizes, contains('w342'));
      expect(fallback.backdropSizes, contains('w780'));
      expect(fallback.profileSizes, contains('w185'));
    });
  });
}
