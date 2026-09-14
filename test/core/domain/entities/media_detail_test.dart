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
    test('picks the first YouTube video of type Trailer', () {
      final detail = _detail(
        videos: const [
          Video(key: 'a', site: 'YouTube', type: 'Teaser', name: 'Teaser'),
          Video(key: 'b', site: 'Vimeo', type: 'Trailer', name: 'Not YouTube'),
          Video(key: 'c', site: 'YouTube', type: 'Trailer', name: 'Trailer 1'),
          Video(key: 'd', site: 'YouTube', type: 'Trailer', name: 'Trailer 2'),
        ],
      );

      expect(detail.trailer?.key, 'c');
    });

    test('is null when there is no YouTube Trailer', () {
      final detail = _detail(
        videos: const [
          Video(key: 'a', site: 'YouTube', type: 'Teaser', name: 'Teaser'),
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
