import 'package:flutter/widgets.dart';

import '../domain/entities/genre.dart';
import '../domain/entities/genre_catalog.dart';
import 'app_icons.dart';

/// Every selectable genre paired with its icon — [GenreCatalog.all]
/// stays pure (no Flutter/icons); this resolves each one to its
/// `AppIcons.genreXxx` constant, the same split `vibe.dart`'s own icon
/// field already uses.
///
/// Promoted from `features/my_tastes/presentation/screens/
/// genre_options.dart` to `core/theme/` once `quiz_genre_step.dart`
/// (E2) became this list's second real consumer, alongside
/// `TasteGenreGrid`'s own `options` (C5) — the same "second genuine
/// consumer" bar this codebase already applies elsewhere (e.g.
/// `MediaSegmentedControl`, `ExploreFilterSheet`).
final List<(Genre, IconData)> genreOptions = [
  for (final genre in GenreCatalog.all) (genre, _icons[genre.id]!),
];

/// [genre]'s icon, a film strip for one outside the catalog.
IconData genreIconOf(Genre genre) => _icons[genre.id] ?? AppIcons.movie;

const Map<String, IconData> _icons = {
  'action': AppIcons.genreAction,
  'adventure': AppIcons.genreAdventure,
  'animation': AppIcons.genreAnimation,
  'comedy': AppIcons.genreComedy,
  'crime': AppIcons.genreCrime,
  'documentary': AppIcons.genreDocumentary,
  'drama': AppIcons.genreDrama,
  'family': AppIcons.genreFamily,
  'fantasy': AppIcons.genreFantasy,
  'history': AppIcons.genreHistory,
  'horror': AppIcons.genreHorror,
  'music': AppIcons.genreMusic,
  'mystery': AppIcons.genreMystery,
  'romance': AppIcons.genreRomance,
  'sci-fi': AppIcons.genreSciFi,
  'thriller': AppIcons.genreThriller,
  'war': AppIcons.genreWar,
  'western': AppIcons.genreWestern,
};
