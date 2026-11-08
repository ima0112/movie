import '../features/person_detail/presentation/widgets/filmography_grouping.dart';
import 'app_localizations.dart';

/// The single mapper from [FilmographySegment] to its segmented-control
/// label — CLAUDE.md rule 15. [FilmographySegment.movies]/[.tvShows]
/// reuse the same plural wording as
/// [MediaTypeLocalization.localizedPlural] (`media_type_localization.dart`).
extension FilmographySegmentLocalization on FilmographySegment {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    FilmographySegment.all => l10n.mediaSegmentAll,
    FilmographySegment.movies => l10n.mediaTypeMoviePlural,
    FilmographySegment.tvShows => l10n.mediaTypeTvShowPlural,
    FilmographySegment.asDirector => l10n.personFilmographyAsDirector,
  };
}
