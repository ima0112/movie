import 'package:flutter/widgets.dart';

import '../../../../core/domain/entities/genre.dart';
import '../../../../core/domain/entities/genre_catalog.dart';
import '../../../../core/theme/app_icons.dart';

/// Every selectable genre paired with its icon, ready for
/// `TasteGenreGrid`'s `options` — [GenreCatalog.all] stays pure (no
/// Flutter/icons); this resolves each one to its `AppIcons.genreXxx`
/// constant, the same split `vibe.dart`'s own icon field already uses.
final List<(Genre, IconData)> genreOptions = [
  for (final genre in GenreCatalog.all) (genre, _icons[genre.id]!),
];

const Map<String, IconData> _icons = {
  'action': AppIcons.genreAction,
  'adventure': AppIcons.genreAdventure,
  'animation': AppIcons.genreAnimation,
  'comedy': AppIcons.genreComedy,
  'crime': AppIcons.genreCrime,
  'documentary': AppIcons.genreDocumentary,
  'drama': AppIcons.genreDrama,
  'family': AppIcons.genreFamily,
  'history': AppIcons.genreHistory,
  'horror': AppIcons.genreHorror,
  'music': AppIcons.genreMusic,
  'mystery': AppIcons.genreMystery,
  'romance': AppIcons.genreRomance,
  'sci-fi': AppIcons.genreSciFi,
  'thriller': AppIcons.genreThriller,
};
