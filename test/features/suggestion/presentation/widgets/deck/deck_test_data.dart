import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_detail.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/season_summary.dart';
import 'package:movies/core/domain/entities/streaming_service.dart';
import 'package:movies/core/domain/entities/watch_providers.dart';
import 'package:movies/features/match_engine/domain/surprise_batch.dart';

List<StreamingService> services(int n) => [
  for (var i = 1; i <= n; i++) StreamingService(id: i, name: 'Service $i'),
];

/// "Dune: Part Two" — 2024 · 2 h 46 min, 8.2, with a tagline.
SurpriseSuggestion movieSuggestion({
  int percent = 88,
  List<StreamingService> platforms = const [],
  String? tagline = 'Long live the fighters.',
  int? runtime = 166,
  String? posterUrl,
  String title = 'Dune: Part Two',
}) {
  final item = Movie(
    id: 1,
    title: title,
    posterUrl: posterUrl,
    genres: const [Genre(id: 'sci-fi')],
    releaseDate: DateTime(2024, 3),
    voteAverage: 8.2,
    voteCount: 5000,
  );
  return SurpriseSuggestion(
    detail: MovieDetail(
      item: item,
      overview: '',
      cast: const [],
      crew: const [],
      videos: const [],
      similar: const [],
      imdbId: null,
      tagline: tagline,
      status: 'Released',
      watchProviders: WatchProviders.empty,
      runtimeMinutes: runtime,
      releaseDate: item.releaseDate,
      certification: null,
    ),
    affinityPercent: percent,
    platforms: platforms,
  );
}

SeasonSummary _season(int n) => SeasonSummary(
  seasonNumber: n,
  name: 'Season $n',
  episodeCount: 8,
  posterPath: null,
  airDate: null,
);

/// "Dark" — [first]–[last], [seasons] seasons (plus a specials season 0).
SurpriseSuggestion showSuggestion({
  int first = 2017,
  int? last = 2020,
  int seasons = 3,
  bool airing = false,
  List<StreamingService> platforms = const [],
  String? tagline = 'A labyrinth in time.',
}) {
  final item = TvShow(
    id: 2,
    title: 'Dark',
    posterUrl: null,
    genres: const [],
    releaseDate: DateTime(first),
    voteAverage: 8.7,
    voteCount: 3000,
  );
  return SurpriseSuggestion(
    detail: TvShowDetail(
      item: item,
      overview: '',
      cast: const [],
      crew: const [],
      videos: const [],
      similar: const [],
      imdbId: null,
      tagline: tagline,
      status: airing ? 'Returning Series' : 'Ended',
      watchProviders: WatchProviders.empty,
      creators: const [],
      seasons: [_season(0), for (var i = 1; i <= seasons; i++) _season(i)],
      numberOfEpisodes: seasons * 8,
      episodeRuntimeMinutes: 50,
      firstAirDate: DateTime(first),
      lastAirDate: last == null ? null : DateTime(last),
      inProduction: airing,
      certification: null,
    ),
    affinityPercent: 88,
    platforms: platforms,
  );
}
