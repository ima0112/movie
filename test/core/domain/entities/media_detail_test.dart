import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_detail.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/video.dart';
import 'package:movies/core/domain/entities/watch_providers.dart';

Movie _movie() {
  return Movie(
    id: 1,
    title: 'Dune: Part Two',
    posterUrl: null,
    genres: const [],
    releaseDate: DateTime(2024, 3, 1),
    voteAverage: 8.4,
  );
}

MovieDetail _detail({required List<Video> videos}) {
  return MovieDetail(
    item: _movie(),
    overview: 'A young man goes on a journey.',
    cast: const [],
    crew: const [],
    videos: videos,
    similar: const [],
    imdbId: null,
    tagline: null,
    status: 'Released',
    watchProviders: WatchProviders.empty,
    runtimeMinutes: 166,
    releaseDate: DateTime(2024, 3, 1),
    certification: null,
  );
}

void main() {
  group('MediaDetail.trailer', () {
    test('tier 1: official + Trailer + user\'s language (es) wins over '
        'everything else', () {
      final detail = _detail(
        videos: const [
          Video(
            key: 'a',
            site: 'YouTube',
            type: 'Trailer',
            name: 'Official EN',
            official: true,
            iso6391: 'en',
          ),
          Video(
            key: 'b',
            site: 'YouTube',
            type: 'Trailer',
            name: 'Official ES',
            official: true,
            iso6391: 'es',
          ),
        ],
      );

      expect(detail.trailer?.key, 'b');
    });

    test('tier 2: no es-language official Trailer -> any official video', () {
      final detail = _detail(
        videos: const [
          Video(
            key: 'a',
            site: 'YouTube',
            type: 'Teaser',
            name: 'Official Teaser',
            official: true,
          ),
          Video(key: 'b', site: 'YouTube', type: 'Trailer', name: 'Fan-made'),
        ],
      );

      expect(detail.trailer?.key, 'a');
    });

    test('tier 3: nothing official -> a Teaser', () {
      final detail = _detail(
        videos: const [
          Video(key: 'a', site: 'YouTube', type: 'Clip', name: 'Clip'),
          Video(key: 'b', site: 'YouTube', type: 'Teaser', name: 'Teaser'),
        ],
      );

      expect(detail.trailer?.key, 'b');
    });

    test('tier 4: nothing official and no Teaser -> the first available '
        'YouTube video', () {
      final detail = _detail(
        videos: const [
          Video(key: 'a', site: 'YouTube', type: 'Clip', name: 'Clip'),
          Video(key: 'b', site: 'YouTube', type: 'Featurette', name: 'BTS'),
        ],
      );

      expect(detail.trailer?.key, 'a');
    });

    test('a non-YouTube video never wins, at any tier', () {
      final detail = _detail(
        videos: const [
          Video(
            key: 'a',
            site: 'Vimeo',
            type: 'Trailer',
            name: 'Not YouTube',
            official: true,
            iso6391: 'es',
          ),
          Video(key: 'b', site: 'YouTube', type: 'Clip', name: 'Clip'),
        ],
      );

      expect(detail.trailer?.key, 'b');
    });

    test('is null when there is no YouTube video at all', () {
      final detail = _detail(
        videos: const [
          Video(key: 'a', site: 'Vimeo', type: 'Trailer', name: 'Not YouTube'),
        ],
      );

      expect(detail.trailer, isNull);
    });
  });

  group('TvShowDetail.estimatedHours', () {
    TvShowDetail detail({
      int numberOfEpisodes = 10,
      int? episodeRuntimeMinutes,
    }) {
      return TvShowDetail(
        item: _movie(),
        overview: 'A group of friends run a restaurant.',
        cast: const [],
        crew: const [],
        videos: const [],
        similar: const [],
        imdbId: null,
        tagline: null,
        status: 'Ended',
        watchProviders: WatchProviders.empty,
        creators: const [],
        seasons: const [],
        numberOfEpisodes: numberOfEpisodes,
        episodeRuntimeMinutes: episodeRuntimeMinutes,
        firstAirDate: null,
        lastAirDate: null,
        inProduction: false,
        certification: null,
      );
    }

    test('uses the real episode runtime when TMDB has one', () {
      final show = detail(numberOfEpisodes: 10, episodeRuntimeMinutes: 30);

      expect(show.estimatedHours, 10 * 30 / 60);
    });

    test('falls back to 45 min/episode when TMDB has no runtime', () {
      final show = detail(numberOfEpisodes: 8, episodeRuntimeMinutes: null);

      expect(show.estimatedHours, 8 * 45 / 60);
    });
  });
}
