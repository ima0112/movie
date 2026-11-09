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

void main() {
  group('tvYearRange', () {
    test('a multi-year show shows first–last', () {
      expect(
        tvYearRange(
          _show(
            firstAirDate: DateTime(2008, 1, 20),
            lastAirDate: DateTime(2013, 9, 29),
          ),
        ),
        '2008–2013',
      );
    });

    test('a single year, or an unknown last year, shows just the first', () {
      expect(
        tvYearRange(
          _show(
            firstAirDate: DateTime(2024, 1, 1),
            lastAirDate: DateTime(2024, 12, 1),
          ),
        ),
        '2024',
      );
      expect(tvYearRange(_show(firstAirDate: DateTime(2024, 1, 1))), '2024');
    });

    test('no first air date: null', () {
      expect(tvYearRange(_show()), isNull);
    });
  });
}
