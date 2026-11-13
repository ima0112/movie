import 'package:flutter/material.dart';

import '../../../../core/domain/entities/discover_filter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/discover_sort_by_localization.dart';
import '../../../../l10n/l10n_extension.dart';

/// C1's line under the filter chips: the count of results on the left
/// ("38 results" — TMDB's true total, not what the grid has revealed so far)
/// and the current sort on the right with a chevron, which opens the sort
/// sheet via [onSortTap].
class FilteredListCountLine extends StatelessWidget {
  const FilteredListCountLine({
    super.key,
    required this.count,
    required this.sortBy,
    required this.onSortTap,
  });

  final int count;
  final DiscoverSortBy sortBy;
  final VoidCallback onSortTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.filteredListCount(count),
          style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onSortTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(sortBy.sheetLabel(l10n), style: AppTextStyles.bodySmStrong),
              const SizedBox(width: AppSpacing.xs),
              const Icon(
                AppIcons.chevronDown,
                size: AppSpacing.xl,
                color: AppColors.ink,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
