import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/launch/app_link.dart';

void main() {
  const movie = MediaKey(type: MediaType.movie, tmdbId: 603);
  const show = MediaKey(type: MediaType.tvShow, tmdbId: 1396);

  group('appLinkFor', () {
    test('a movie and a show', () {
      expect(appLinkFor(movie).toString(), 'pickme://app/movie/603');
      expect(appLinkFor(show).toString(), 'pickme://app/tv/1396');
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
        mediaKeyFromAppLink(Uri.parse('pickme://app/movie/27205')),
        const MediaKey(type: MediaType.movie, tmdbId: 27205),
      );
    });

    test('anything that is not ours or not whole is not a link', () {
      for (final bad in [
        'https://app/movie/603', // another scheme
        'pickme://other/movie/603', // another host
        'pickme://movie/603', // the kind of title taken for the host
        'pickme://app/person/603', // not a title
        'pickme://app/movie', // no id
        'pickme://app/movie/abc', // not a number
        'pickme://app/movie/0', // not an id
        'pickme://app/movie/-3',
        'pickme://app/movie/603/extra', // more than a title
        'pickme://app/',
        'pickme://app',
        '/movie/603', // an in-app route, not a link
      ]) {
        expect(mediaKeyFromAppLink(Uri.parse(bad)), isNull, reason: bad);
      }
    });
  });
}
