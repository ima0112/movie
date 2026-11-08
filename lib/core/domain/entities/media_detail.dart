import 'media_item.dart';
import 'person.dart';
import 'season_summary.dart';
import 'video.dart';
import 'watch_providers.dart';

/// A catalog item's full detail — D1 (movie) / D2 (TV show). See
/// `media_item.dart` for the list-level entity this builds on.
///
/// Grouped with its variants ([MovieDetail], [TvShowDetail]) in one file
/// per CLAUDE.md rule 13: splitting a sealed family across files hurts
/// readability of the exhaustiveness the compiler enforces on it.
sealed class MediaDetail {
  const MediaDetail({
    required this.item,
    required this.overview,
    required this.cast,
    required this.crew,
    required this.videos,
    required this.similar,
    required this.imdbId,
    required this.tagline,
    required this.status,
    required this.watchProviders,
  });

  final MediaItem item;

  /// D1/D2's synopsis — "folded to 4 lines with an amber 'Read more'". Can
  /// be empty when TMDB has none for the user's language.
  final String overview;

  final List<CastMember> cast;
  final List<CrewMember> crew;
  final List<Video> videos;
  final List<MediaItem> similar;
  final String? imdbId;
  final String? tagline;
  final String status;
  final WatchProviders watchProviders;

  /// The trailer button's pick — see `docs/SCREENS.md` D1: "official +
  /// Trailer + user's language → official → Teaser → first available."
  /// TODO: this only picks the first YouTube "Trailer"; the full
  /// selection order isn't implemented yet.
  Video? get trailer {
    for (final v in videos) {
      if (v.isYoutube && v.type == 'Trailer') return v;
    }
    return null;
  }
}

final class MovieDetail extends MediaDetail {
  const MovieDetail({
    required super.item,
    required super.overview,
    required super.cast,
    required super.crew,
    required super.videos,
    required super.similar,
    required super.imdbId,
    required super.tagline,
    required super.status,
    required super.watchProviders,
    required this.runtimeMinutes,
    required this.releaseDate,
    required this.certification,
  });

  final int? runtimeMinutes;
  final DateTime? releaseDate;
  final String? certification;
}

final class TvShowDetail extends MediaDetail {
  const TvShowDetail({
    required super.item,
    required super.overview,
    required super.cast,
    required super.crew,
    required super.videos,
    required super.similar,
    required super.imdbId,
    required super.tagline,
    required super.status,
    required super.watchProviders,
    required this.creators,
    required this.seasons,
    required this.numberOfEpisodes,
    required this.episodeRuntimeMinutes,
    required this.firstAirDate,
    required this.lastAirDate,
    required this.inProduction,
  });

  final List<Person> creators;
  final List<SeasonSummary> seasons;
  final int numberOfEpisodes;
  final int? episodeRuntimeMinutes;
  final DateTime? firstAirDate;
  final DateTime? lastAirDate;
  final bool inProduction;

  /// Stats' "Estimated TV hours" — falls back to 45 min/episode when TMDB
  /// doesn't give a runtime.
  double get estimatedHours =>
      numberOfEpisodes * (episodeRuntimeMinutes ?? 45) / 60;
}
