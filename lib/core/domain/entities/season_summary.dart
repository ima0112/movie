import 'person.dart';

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
    this.voteAverage,
  });

  final int seasonNumber;
  final String name;
  final int episodeCount;
  final String? posterPath;
  final DateTime? airDate;

  /// TMDB's average rating for the season, or `null` when nobody has voted.
  final double? voteAverage;
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
    this.voteAverage,
    this.guestStars = const [],
  });

  final int episodeNumber;
  final String name;
  final String overview;
  final String? stillPath;
  final DateTime? airDate;
  final int? runtimeMinutes;

  /// TMDB's average rating, or `null` when nobody has voted.
  final double? voteAverage;

  /// The episode's guest stars (empty when TMDB lists none).
  final List<CastMember> guestStars;
}

/// `MediaRepository.season(tvId, n)`'s own result — H4's "Title, season
/// synopsis, episode list" (`docs/SCREENS.md` H4). [SeasonSummary] (the
/// row shown in D2's "Seasons" section, before a season is ever opened)
/// already carries [seasonNumber]/[name]; this is what H4 fetches once
/// a specific row is tapped — the season's own synopsis plus its full
/// [Episode] list, neither of which D2's single `/tv/{id}` call carries.
final class SeasonDetail {
  const SeasonDetail({
    required this.seasonNumber,
    required this.name,
    required this.overview,
    required this.episodes,
  });

  final int seasonNumber;
  final String name;
  final String overview;
  final List<Episode> episodes;
}

/// A show's most recently aired or next scheduled episode, as `/tv/{id}`
/// reports it (D2's "Seasons" screen) — just enough to label it and show its
/// still, not a full [Episode] (no synopsis or runtime).
final class EpisodeRef {
  const EpisodeRef({
    required this.seasonNumber,
    required this.episodeNumber,
    required this.name,
    required this.airDate,
    required this.stillPath,
    required this.voteAverage,
  });

  final int seasonNumber;
  final int episodeNumber;
  final String name;
  final DateTime? airDate;
  final String? stillPath;
  final double? voteAverage;
}
