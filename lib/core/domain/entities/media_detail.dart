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
    this.backdropUrl,
    this.originalLanguage,
    this.countryCodes = const [],
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

  /// A full-width 16:9 backdrop URL for the detail header, or `null` when
  /// TMDB has none (the header then falls back to the poster).
  final String? backdropUrl;

  /// ISO 639-1 code of the original language (`en`), or `null`.
  final String? originalLanguage;

  /// ISO 3166-1 codes of the production / origin countries, first = main.
  final List<String> countryCodes;

  /// The user's own language, for [trailer]'s own "+ user's language"
  /// tier — matches `LocaleInterceptor`'s own `en`/`US` default, since
  /// no real settings source exists yet.
  static const _userLanguage = 'en';

  /// The trailer button's pick — `docs/SCREENS.md` D1: "official +
  /// Trailer + user's language → official → Teaser → first available."
  /// Only ever a YouTube video (`docs/SCREENS.md` D1: "opens YouTube") —
  /// a non-YouTube video can't be "played" by this button at all, so it
  /// never competes with a YouTube one, at any tier.
  Video? get trailer {
    final youtube = videos.where((v) => v.isYoutube);
    if (youtube.isEmpty) return null;

    for (final v in youtube) {
      if (v.official && v.type == 'Trailer' && v.iso6391 == _userLanguage) {
        return v;
      }
    }
    for (final v in youtube) {
      if (v.official) return v;
    }
    for (final v in youtube) {
      if (v.type == 'Teaser') return v;
    }
    return youtube.first;
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
    super.backdropUrl,
    super.originalLanguage,
    super.countryCodes,
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
    super.backdropUrl,
    super.originalLanguage,
    super.countryCodes,
    required this.creators,
    required this.seasons,
    required this.numberOfEpisodes,
    required this.episodeRuntimeMinutes,
    required this.firstAirDate,
    required this.lastAirDate,
    required this.inProduction,
    required this.certification,
    this.lastEpisode,
    this.nextEpisode,
  });

  final List<Person> creators;
  final List<SeasonSummary> seasons;
  final int numberOfEpisodes;
  final int? episodeRuntimeMinutes;
  final DateTime? firstAirDate;
  final DateTime? lastAirDate;
  final bool inProduction;

  /// The most recently aired / next scheduled episode, or `null`.
  final EpisodeRef? lastEpisode;
  final EpisodeRef? nextEpisode;

  /// D2's own metadata-line rating, e.g. "TV-14" — TMDB's `content_
  /// ratings`, the show-level equivalent of [MovieDetail.certification]
  /// (`docs/SCREENS.md` D2: "Year–Year · N seasons · M episodes ·
  /// Rating").
  final String? certification;

  /// Stats' "Estimated TV hours" — falls back to 45 min/episode when TMDB
  /// doesn't give a runtime.
  double get estimatedHours =>
      numberOfEpisodes * (episodeRuntimeMinutes ?? 45) / 60;
}
