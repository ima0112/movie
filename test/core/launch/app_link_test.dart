import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/launch/app_link.dart';

void main() {
  const movie = MediaKey(type: MediaType.movie, tmdbId: 603);
  const show = MediaKey(type: MediaType.tvShow, tmdbId: 1396);

  group('appLinkFor', () {
    test('a movie and a show', () {
      expect(appLinkFor(movie).toString(), 'pakotv://app/movie/603');
      expect(appLinkFor(show).toString(), 'pakotv://app/tv/1396');
    });

    test('the path is the app\'s own route, behind a placeholder host', () {
      final link = appLinkFor(movie);
      expect(link.host, 'app');
      expect(link.path, '/movie/603');
    });
  });

  group('mediaKeyFromAppLink', () {
    test('reads back what appLinkFor builds', () {
      expect(mediaKeyFromAppLink(appLinkFor(movie)), movie);
      expect(mediaKeyFromAppLink(appLinkFor(show)), show);
    });

    test('a link typed by hand', () {
      expect(
        mediaKeyFromAppLink(Uri.parse('pakotv://app/movie/27205')),
        const MediaKey(type: MediaType.movie, tmdbId: 27205),
      );
    });

    test('anything that is not ours or not whole is not a link', () {
      for (final bad in [
        'https://app/movie/603', // another scheme
        'pakotv://other/movie/603', // another host
        'pakotv://movie/603', // the kind of title taken for the host
        'pakotv://app/person/603', // not a title
        'pakotv://app/movie', // no id
        'pakotv://app/movie/abc', // not a number
        'pakotv://app/movie/0', // not an id
        'pakotv://app/movie/-3',
        'pakotv://app/movie/603/extra', // more than a title
        'pakotv://app/',
        'pakotv://app',
        '/movie/603', // an in-app route, not a link
      ]) {
        expect(mediaKeyFromAppLink(Uri.parse(bad)), isNull, reason: bad);
      }
    });
  });
}
