import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/my_list_sort_localization.dart';
import '../../../../shared/widgets/app_chip.dart';
import '../cubit/my_list_cubit.dart';

/// H9's Sort chip row, split out of `my_list_filter_sheet.dart` per
/// CLAUDE.md rule 11. Pure presentation — no `MyListCubit` dependency;
/// the sheet owns the draft `TabFilter` and passes this row its value.
///
/// `FilterSectionLabel` and `TypeFilterChips` (H9's other two rows) used
/// to live here too — promoted to `shared/widgets/filter_controls.dart`
/// once H8 needed the exact same "Type" chips, rather than duplicate
/// them for a second filter sheet.
class SortFilterChips extends StatelessWidget {
  const SortFilterChips({
    super.key,
    required this.options,
    required this.sort,
    required this.onChanged,
  });

  final List<MyListSort> options;
  final MyListSort sort;
  final ValueChanged<MyListSort> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final option in options)
          AppChip(
            label: option.localizedLabel(l10n),
            state: option == sort ? ChipState.selected : ChipState.normal,
            onTap: () => onChanged(option),
          ),
      ],
    );
  }
}
