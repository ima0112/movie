import 'package:flutter/material.dart';

import '../../core/domain/entities/genre.dart';
import '../../core/theme/app_spacing.dart';
import '../../l10n/genre_localization.dart';
import '../../l10n/l10n_extension.dart';
import 'app_chip.dart';

/// H8: "multi-select genres" (`docs/SCREENS.md` H8) — plain flowing
/// chips, not C5's 3-column `QuizTile` grid: a filter sheet's genre
/// picker is a much smaller, secondary control there, not its own
/// dedicated screen section.
///
/// Pure presentation — no feature dependency, everything comes in by
/// parameter.
class GenreMultiSelectChips extends StatelessWidget {
  const GenreMultiSelectChips({
    super.key,
    required this.genres,
    required this.selected,
    required this.onToggle,
  });

  final List<Genre> genres;
  final Set<Genre> selected;
  final ValueChanged<Genre> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final genre in genres)
          AppChip(
            label: genre.localizedName(context.l10n),
            state: selected.contains(genre)
                ? ChipState.selected
                : ChipState.normal,
            onTap: () => onToggle(genre),
          ),
      ],
    );
  }
}
