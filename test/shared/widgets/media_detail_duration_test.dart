import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_detail.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/watch_providers.dart';
import 'package:movies/shared/widgets/media_detail_duration.dart';

Movie _movie() => Movie(
  id: 1,
  title: 'Dune: Part Two',
  posterUrl: null,
  genres: const [],
  releaseDate: DateTime(2024, 3, 1),
  voteAverage: 8.4,
);

MovieDetail _movieDetail({int? runtimeMinutes}) => MovieDetail(
  item: _movie(),
  overview: '',
  cast: const [],
  crew: const [],
  videos: const [],
  similar: const [],
  imdbId: null,
  tagline: null,
  status: 'Released',
  watchProviders: WatchProviders.empty,
  runtimeMinutes: runtimeMinutes,
  releaseDate: DateTime(2024, 3, 1),
  certification: null,
);

TvShowDetail _tvShowDetail({
  int numberOfEpisodes = 10,
  int? episodeRuntimeMinutes,
}) => TvShowDetail(
  item: _movie(),
  overview: '',
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

void main() {
  group('durationFieldsFrom', () {
    test('a MovieDetail populates runtimeMinutes only', () {
      final fields = durationFieldsFrom(_movieDetail(runtimeMinutes: 166));

      expect(fields.runtimeMinutes, 166);
      expect(fields.episodeCount, isNull);
      expect(fields.episodeRuntimeMinutes, isNull);
    });

    test(
      'a TvShowDetail populates episodeCount/episodeRuntimeMinutes only',
      () {
        final fields = durationFieldsFrom(
          _tvShowDetail(numberOfEpisodes: 62, episodeRuntimeMinutes: 24),
        );

        expect(fields.runtimeMinutes, isNull);
        expect(fields.episodeCount, 62);
        expect(fields.episodeRuntimeMinutes, 24);
      },
    );

    test('a movie with no known runtime from TMDB still comes back null, '
        'not an error', () {
      final fields = durationFieldsFrom(_movieDetail(runtimeMinutes: null));

      expect(fields.runtimeMinutes, isNull);
    });

    test('null detail comes back as all-null fields', () {
      final fields = durationFieldsFrom(null);

      expect(fields.runtimeMinutes, isNull);
      expect(fields.episodeCount, isNull);
      expect(fields.episodeRuntimeMinutes, isNull);
    });
  });
}
