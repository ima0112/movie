import '../core/domain/entities/genre.dart';
import 'app_localizations.dart';

/// The single mapper from a [Genre]'s stable [Genre.id] to its display
/// name — CLAUDE.md rule 15: `domain`/`data` never contain user-facing
/// text, so [Genre] carries only an [Genre.id] and every screen that
/// shows one calls `genre.localizedName(context.l10n)`.
///
/// Exhaustive over `GenreCatalog.all`'s own ids (no `default`/`_`
/// branch) so adding a genre to the catalog without adding it here is a
/// compile error, not a silently blank label.
extension GenreLocalization on Genre {
  String localizedName(AppLocalizations l10n) => switch (id) {
    'action' => l10n.genreAction,
    'adventure' => l10n.genreAdventure,
    'animation' => l10n.genreAnimation,
    'comedy' => l10n.genreComedy,
    'crime' => l10n.genreCrime,
    'documentary' => l10n.genreDocumentary,
    'drama' => l10n.genreDrama,
    'family' => l10n.genreFamily,
    'history' => l10n.genreHistory,
    'horror' => l10n.genreHorror,
    'music' => l10n.genreMusic,
    'mystery' => l10n.genreMystery,
    'romance' => l10n.genreRomance,
    'sci-fi' => l10n.genreSciFi,
    'thriller' => l10n.genreThriller,
    _ => throw ArgumentError('Unknown genre id: $id'),
  };
}
