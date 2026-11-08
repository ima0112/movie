import '../core/domain/entities/media_type.dart';
import 'app_localizations.dart';

/// The single mapper from [MediaType] to display text — CLAUDE.md rule
/// 15: `domain`/`data` never contain user-facing text, so every screen
/// that shows a [MediaType] calls one of these rather than hardcoding
/// "Movie"/"TV Show" itself.
extension MediaTypeLocalization on MediaType {
  /// "Movie" / "TV Show".
  String localizedSingular(AppLocalizations l10n) => switch (this) {
    MediaType.movie => l10n.mediaTypeMovieSingular,
    MediaType.tvShow => l10n.mediaTypeTvShowSingular,
  };

  /// "Movies" / "TV Shows".
  String localizedPlural(AppLocalizations l10n) => switch (this) {
    MediaType.movie => l10n.mediaTypeMoviePlural,
    MediaType.tvShow => l10n.mediaTypeTvShowPlural,
  };
}
