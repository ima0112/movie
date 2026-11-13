import 'package:flutter/material.dart';

import '../../../../core/domain/entities/discover_filter.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/discover_sort_by_localization.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/checkable_option_row.dart';
import '../../../../shared/widgets/discover_sort_chips.dart';

/// The sheet behind C1's sort control: the same three orders as H8's "Sort
/// by", single select with an amber check; tapping applies and closes.
class FilteredListSortSheet extends StatelessWidget {
  const FilteredListSortSheet({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final DiscoverSortBy selected;
  final ValueChanged<DiscoverSortBy> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.filterSheetSectionSortBy, style: AppTextStyles.h1),
            const SizedBox(height: AppSpacing.lg),
            for (final (i, sort) in DiscoverSortChips.options.indexed) ...[
              if (i > 0) const Divider(height: 1),
              CheckableOptionRow(
                label: sort.sheetLabel(l10n),
                isSelected: sort == selected,
                onTap: () {
                  onSelected(sort);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
