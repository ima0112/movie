import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/launch/media_share.dart';

void main() {
  const movie = MediaKey(type: MediaType.movie, tmdbId: 27205);
  const show = MediaKey(type: MediaType.tvShow, tmdbId: 1396);

  test('a movie shares its /movie/{id} TMDB page', () {
    expect(tmdbShareUrl(movie), 'https://www.themoviedb.org/movie/27205');
  });

  test('a TV show shares its /tv/{id} TMDB page', () {
    expect(tmdbShareUrl(show), 'https://www.themoviedb.org/tv/1396');
  });

  test('the share text is the title, then the link on its own line', () {
    expect(
      mediaShareText(title: 'Inception', key: movie),
      'Inception\nhttps://www.themoviedb.org/movie/27205',
    );
  });
}
