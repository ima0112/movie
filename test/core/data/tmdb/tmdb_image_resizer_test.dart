import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/tmdb/tmdb_image_resizer.dart';
import 'package:movies/core/data/tmdb/tmdb_image_urls.dart';

const _config = TmdbImagesConfig.fallback();
const _base = 'https://image.tmdb.org/t/p/';

String _poster(String url, double px, {String max = 'w780'}) =>
    TmdbImageResizer.resize(
      url: url,
      kind: TmdbImageKind.poster,
      neededPixels: px,
      maxSize: max,
      config: _config,
    );

void main() {
  group('posters', () {
    test('a hero card (360 dp on a 3x screen = 1080 px) asks for the largest '
        'size allowed, w780, not "original"', () {
      expect(_poster('${_base}w342/abc.jpg', 1080), '${_base}w780/abc.jpg');
    });

    test('a list poster (110 dp x 3 = 330 px) keeps w342', () {
      expect(_poster('${_base}w342/abc.jpg', 330), '${_base}w342/abc.jpg');
    });

    test('it also goes down: a thumbnail needing 120 px gets w154, not the '
        'w500 the URL had', () {
      expect(_poster('${_base}w500/abc.jpg', 120), '${_base}w154/abc.jpg');
    });

    test('the smallest size that covers the need: 400 px -> w500', () {
      expect(_poster('${_base}w185/abc.jpg', 400), '${_base}w500/abc.jpg');
    });

    test('a size 10% short still counts (192 px with w185 on offer)', () {
      expect(_poster('${_base}w342/abc.jpg', 192), '${_base}w185/abc.jpg');
      // 150 px is more than 10% over w154? no: w154 covers it.
      expect(_poster('${_base}w342/abc.jpg', 150), '${_base}w154/abc.jpg');
    });

    test('the cap wins over the need, and "original" is never chosen', () {
      expect(_poster('${_base}w342/abc.jpg', 5000), '${_base}w780/abc.jpg');
      expect(
        _poster('${_base}w342/abc.jpg', 5000, max: 'w500'),
        '${_base}w500/abc.jpg',
      );
    });

    test('an "original" cap means the largest sized option, still not '
        'original itself', () {
      expect(
        _poster('${_base}w342/abc.jpg', 5000, max: 'original'),
        '${_base}w780/abc.jpg',
      );
    });
  });

  group('the other kinds read their own size list', () {
    test('backdrops: 780 px -> w780, 2000 px capped at w1280', () {
      String backdrop(double px) => TmdbImageResizer.resize(
        url: '${_base}w780/back.jpg',
        kind: TmdbImageKind.backdrop,
        neededPixels: px,
        maxSize: 'w1280',
        config: _config,
      );
      expect(backdrop(700), '${_base}w780/back.jpg');
      expect(backdrop(2000), '${_base}w1280/back.jpg');
      expect(backdrop(250), '${_base}w300/back.jpg');
    });

    test('stills and profiles', () {
      expect(
        TmdbImageResizer.resize(
          url: '${_base}w300/still.jpg',
          kind: TmdbImageKind.still,
          neededPixels: 200,
          maxSize: 'w300',
          config: _config,
        ),
        '${_base}w185/still.jpg',
      );
      expect(
        TmdbImageResizer.resize(
          url: '${_base}w185/face.jpg',
          kind: TmdbImageKind.profile,
          neededPixels: 192,
          maxSize: 'w185',
          config: _config,
        ),
        '${_base}w185/face.jpg',
      );
    });
  });

  group('what it leaves alone', () {
    test('a URL that is not a TMDB image (a YouTube thumbnail)', () {
      const yt = 'https://img.youtube.com/vi/abc/hqdefault.jpg';
      expect(_poster(yt, 1000), yt);
    });

    test('a bare path or an empty string', () {
      expect(_poster('/abc.jpg', 300), '/abc.jpg');
      expect(_poster('', 300), '');
    });

    test('a query string or fragment is not mistaken for the path', () {
      const url = '${_base}w342/abc.jpg?x=1';
      expect(_poster(url, 1080), url);
    });

    test('the real configuration is used: only sizes TMDB lists', () {
      const custom = TmdbImagesConfig(
        secureBaseUrl: _base,
        posterSizes: ['w200', 'w400'],
        backdropSizes: ['w300'],
        profileSizes: ['w45'],
        stillSizes: ['w92'],
      );
      expect(
        TmdbImageResizer.resize(
          url: '${_base}w200/abc.jpg',
          kind: TmdbImageKind.poster,
          neededPixels: 300,
          maxSize: 'w780',
          config: custom,
        ),
        '${_base}w400/abc.jpg',
      );
    });

    test('a kind with no usable size under the cap leaves the URL', () {
      expect(
        TmdbImageResizer.resize(
          url: '${_base}w342/abc.jpg',
          kind: TmdbImageKind.poster,
          neededPixels: 300,
          maxSize: 'w45',
          config: _config,
        ),
        '${_base}w342/abc.jpg',
      );
    });

    test('a poster URL passed off as a backdrop is left alone: its w500 is not '
        'a backdrop size, and w1280 would be a 404 for a poster', () {
      expect(
        TmdbImageResizer.resize(
          url: '${_base}w500/poster.jpg',
          kind: TmdbImageKind.backdrop,
          neededPixels: 1170,
          maxSize: 'w1280',
          config: _config,
        ),
        '${_base}w500/poster.jpg',
      );
    });
  });
}
