import '../../core/domain/entities/media_detail.dart';

/// Pulls the duration fields [UserMediaEntry] needs
/// (`core/domain/entities/user_media_entry.dart`) out of a loaded
/// [MediaDetail] — [MarkAsWatchedSheet]'s "Save" is the one place that
/// needs this, but it's a plain data extraction, not layout or state, so
/// it lives in its own small file rather than inline in that widget
/// purely to keep it under CLAUDE.md rule 11's 150-line soft limit.
///
/// `null` in, or a field TMDB itself didn't give (e.g. a movie with no
/// known runtime), both come back as `null` — [MarkAsWatchedSheet]
/// treats either the same way: fall back to whatever the entry already
/// had, never blank a previously-known value just because this call
/// didn't have a fresher one.
({int? runtimeMinutes, int? episodeCount, int? episodeRuntimeMinutes})
durationFieldsFrom(MediaDetail? detail) => switch (detail) {
  MovieDetail(:final runtimeMinutes) => (
    runtimeMinutes: runtimeMinutes,
    episodeCount: null,
    episodeRuntimeMinutes: null,
  ),
  TvShowDetail(:final numberOfEpisodes, :final episodeRuntimeMinutes) => (
    runtimeMinutes: null,
    episodeCount: numberOfEpisodes,
    episodeRuntimeMinutes: episodeRuntimeMinutes,
  ),
  null => (
    runtimeMinutes: null,
    episodeCount: null,
    episodeRuntimeMinutes: null,
  ),
};
