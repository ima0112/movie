/// A TV show's season, as listed in D2's "Seasons" section.
///
/// Grouped with [Episode] per CLAUDE.md rule 13: both are season-related
/// and both have independent use ahead of them — the future H4 season
/// sheet consumes them on their own, not through `TvShowDetail`
/// (`media_detail.dart`).
final class SeasonSummary {
  const SeasonSummary({
    required this.seasonNumber,
    required this.name,
    required this.episodeCount,
    required this.posterPath,
    required this.airDate,
  });

  final int seasonNumber;
  final String name;
  final int episodeCount;
  final String? posterPath;
  final DateTime? airDate;
}

/// One episode within a season — the future H4 season sheet's episode
/// list.
final class Episode {
  const Episode({
    required this.episodeNumber,
    required this.name,
    required this.overview,
    required this.stillPath,
    required this.airDate,
    required this.runtimeMinutes,
  });

  final int episodeNumber;
  final String name;
  final String overview;
  final String? stillPath;
  final DateTime? airDate;
  final int? runtimeMinutes;
}
