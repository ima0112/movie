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
    this.selectedState = ChipState.selected,
    this.disabled = const {},
    this.alignment = WrapAlignment.start,
  });

  final List<Genre> genres;
  final Set<Genre> selected;
  final ValueChanged<Genre> onToggle;

  /// How a selected genre looks — [ChipState.vetoed] for "never" lists.
  final ChipState selectedState;

  /// Genres that can't be picked here: drawn dimmed ([disabledOpacity]) and
  /// inert — the ones already on the opposite list, so a genre can't be both
  /// liked and avoided.
  final Set<Genre> disabled;

  /// How the chips sit on a row (centered on the onboarding's screens).
  final WrapAlignment alignment;

  static const double disabledOpacity = 0.3;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: alignment,
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final genre in genres)
          disabled.contains(genre)
              ? Opacity(
                  opacity: disabledOpacity,
                  child: IgnorePointer(
                    child: Semantics(
                      enabled: false,
                      child: AppChip(
                        label: genre.localizedName(context.l10n),
                        state: ChipState.normal,
                      ),
                    ),
                  ),
                )
              : AppChip(
                  label: genre.localizedName(context.l10n),
                  state: selected.contains(genre)
                      ? selectedState
                      : ChipState.normal,
                  onTap: () => onToggle(genre),
                ),
      ],
    );
  }
}
