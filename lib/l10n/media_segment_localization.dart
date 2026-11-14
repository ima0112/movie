import '../core/domain/entities/media_segment.dart';
import 'app_localizations.dart';

/// The single mapper from [MediaSegment] to its segmented-control label
/// — CLAUDE.md rule 15. [MediaSegment.movie]/[MediaSegment.tvShow] reuse
/// the same plural wording as [MediaTypeLocalization.localizedPlural]
/// (`media_type_localization.dart`) rather than duplicating it under a
/// different key.
extension MediaSegmentLocalization on MediaSegment {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    MediaSegment.all => l10n.mediaSegmentAll,
    MediaSegment.movie => l10n.mediaTypeMoviePlural,
    MediaSegment.tvShow => l10n.mediaTypeTvShowPlural,
    MediaSegment.person => l10n.mediaSegmentPeople,
  };
}
