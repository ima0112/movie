import '../core/domain/entities/genre.dart';
import '../core/domain/entities/media_type.dart';
import 'app_localizations.dart';

/// The single mapper from a [Genre]'s stable [Genre.id] to its display
/// name — CLAUDE.md rule 15: `domain`/`data` never contain user-facing
/// text, so [Genre] carries only an [Genre.id] and every screen that
/// shows one calls `genre.localizedName(context.l10n)`.
///
/// Covers every `GenreCatalog.all` id — **not actually compile-time
/// exhaustive**, despite `id` being driven off a fixed catalog: `Genre
/// .id` is a plain `String` (`core/domain/entities/genre.dart`), so this
/// is a runtime string switch. The `_ => throw ArgumentError(...)`
/// below is what catches a genre added to the catalog without a
/// matching case here — at the first attempt to render its label, not
/// at compile time. Keep every `GenreCatalog.all` id covered by hand.
extension GenreLocalization on Genre {
  /// [type] `tvShow` names the genres TMDB combines on TV the way TMDB does —
  /// "Action & Adventure", "Sci-Fi & Fantasy", "War & Politics" — because that
  /// is what the chip stands for there (`GenreCatalog.tvMembers`). Without a
  /// type, or for movies, the genre's own name.
  String localizedName(AppLocalizations l10n, {MediaType? type}) {
    if (type == MediaType.tvShow) {
      switch (id) {
        case 'action':
          return l10n.genreActionAdventure;
        case 'sci-fi':
          return l10n.genreSciFiFantasy;
        case 'war':
          return l10n.genreWarPolitics;
      }
    }
    return _ownName(l10n);
  }

  String _ownName(AppLocalizations l10n) => switch (id) {
    'action' => l10n.genreAction,
    'adventure' => l10n.genreAdventure,
    'animation' => l10n.genreAnimation,
    'comedy' => l10n.genreComedy,
    'crime' => l10n.genreCrime,
    'documentary' => l10n.genreDocumentary,
    'drama' => l10n.genreDrama,
    'family' => l10n.genreFamily,
    'fantasy' => l10n.genreFantasy,
    'history' => l10n.genreHistory,
    'horror' => l10n.genreHorror,
    'music' => l10n.genreMusic,
    'mystery' => l10n.genreMystery,
    'romance' => l10n.genreRomance,
    'sci-fi' => l10n.genreSciFi,
    'thriller' => l10n.genreThriller,
    'war' => l10n.genreWar,
    'western' => l10n.genreWestern,
    _ => throw ArgumentError('Unknown genre id: $id'),
  };
}
