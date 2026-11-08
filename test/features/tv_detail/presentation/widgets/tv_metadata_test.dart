import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_detail.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/season_summary.dart';
import 'package:movies/core/domain/entities/watch_providers.dart';
import 'package:movies/features/tv_detail/presentation/widgets/tv_metadata.dart';

TvShowDetail _show({
  DateTime? firstAirDate,
  DateTime? lastAirDate,
  List<SeasonSummary> seasons = const [],
  int numberOfEpisodes = 0,
  String? certification,
}) {
  return TvShowDetail(
    item: TvShow(
      id: 1,
      title: 'Test Show',
      posterUrl: null,
      genres: const [],
      releaseDate: firstAirDate,
      voteAverage: 8,
    ),
    overview: '',
    cast: const [],
    crew: const [],
    videos: const [],
    similar: const [],
    imdbId: null,
    tagline: null,
    status: 'Returning Series',
    watchProviders: WatchProviders.empty,
    creators: const [],
    seasons: seasons,
    numberOfEpisodes: numberOfEpisodes,
    episodeRuntimeMinutes: null,
    firstAirDate: firstAirDate,
    lastAirDate: lastAirDate,
    inProduction: true,
    certification: certification,
  );
}

const _season1 = SeasonSummary(
  seasonNumber: 1,
  name: 'Season 1',
  episodeCount: 8,
  posterPath: null,
  airDate: null,
);
const _season2 = SeasonSummary(
  seasonNumber: 2,
  name: 'Season 2',
  episodeCount: 10,
  posterPath: null,
  airDate: null,
);

void main() {
  group('tvMetadataLine', () {
    test('a multi-year, multi-season show joins year range, seasons, '
        'episodes, and certification', () {
      final line = tvMetadataLine(
        _show(
          firstAirDate: DateTime(2022, 6, 23),
          lastAirDate: DateTime(2024, 6, 27),
          seasons: [_season1, _season2],
          numberOfEpisodes: 18,
          certification: 'TV-MA',
        ),
      );

      expect(line, '2022–2024 · 2 seasons · 18 episodes · TV-MA');
    });

    test('collapses to a single year when first and last air dates fall '
        'in the same year', () {
      final line = tvMetadataLine(
        _show(
          firstAirDate: DateTime(2024, 1, 1),
          lastAirDate: DateTime(2024, 12, 1),
          seasons: [_season1],
          numberOfEpisodes: 8,
        ),
      );

      expect(line, startsWith('2024 ·'));
    });

    test('singular "season"/"episode" for a one-of-each show', () {
      final line = tvMetadataLine(
        _show(
          firstAirDate: DateTime(2024, 1, 1),
          seasons: [_season1],
          numberOfEpisodes: 1,
        ),
      );

      expect(line, contains('1 season ·'));
      expect(line, contains('1 episode'));
    });

    test('omits whatever field has no data, with no stray separators', () {
      final line = tvMetadataLine(_show());

      expect(line, '');
    });
  });
}
