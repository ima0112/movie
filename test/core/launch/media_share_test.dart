import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/launch/media_share.dart';

void main() {
  const movie = MediaKey(type: MediaType.movie, tmdbId: 27205);
  const show = MediaKey(type: MediaType.tvShow, tmdbId: 1396);

  test('the share text is the title, then the link into the app on its own '
      'line', () {
    expect(
      mediaShareText(title: 'Inception', key: movie),
      'Inception\npickme://app/movie/27205',
    );
    expect(
      mediaShareText(title: 'Breaking Bad', key: show),
      'Breaking Bad\npickme://app/tv/1396',
    );
  });

  test('what is shared is no longer the TMDB page', () {
    expect(mediaShareText(title: 'X', key: movie), isNot(contains('tmdb')));
  });
}
