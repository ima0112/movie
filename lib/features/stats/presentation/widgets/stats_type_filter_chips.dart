import 'package:flutter/material.dart';

import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/media_type_localization.dart';
import '../../../../shared/widgets/app_chip.dart';

/// C4's "Filter chips: All · Movies · TV Shows" (`docs/SCREENS.md` C4).
///
/// Driven entirely by [filterType]/[onSelected] — knows nothing about
/// `StatsCubit`, the same pattern `DiscoverSegmentedControl` uses for
/// B1's equivalent row: the screen's own narrowly-scoped `BlocSelector`
/// is what actually reads the Cubit (CLAUDE.md rule 9).
///
/// `null` selects "All".
class StatsTypeFilterChips extends StatelessWidget {
  const StatsTypeFilterChips({
    super.key,
    required this.filterType,
    required this.onSelected,
  });

  final MediaType? filterType;
  final ValueChanged<MediaType?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _chip(label: l10n.mediaSegmentAll, value: null),
        _chip(
          label: MediaType.movie.localizedPlural(l10n),
          value: MediaType.movie,
        ),
        _chip(
          label: MediaType.tvShow.localizedPlural(l10n),
          value: MediaType.tvShow,
        ),
      ],
    );
  }

  Widget _chip({required String label, required MediaType? value}) {
    return AppChip(
      label: label,
      state: value == filterType ? ChipState.selected : ChipState.normal,
      onTap: () => onSelected(value),
    );
  }
}
