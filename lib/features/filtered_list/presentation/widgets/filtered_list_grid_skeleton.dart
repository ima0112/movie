import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/media_card.dart';
import '../../../../shared/widgets/state_views.dart';

/// C1's "grid skeleton" — same 3-column shape as `FilteredListGrid`
/// itself, filled with [SkeletonBlock]s instead of `MediaCard`s.
class FilteredListGridSkeleton extends StatelessWidget {
  const FilteredListGridSkeleton({super.key});

  static const int _crossAxisCount = 3;

  // Four full rows — no data to size this by yet, so it's a fixed count
  // the same way `FilteredListCubit.pageSize` (also four rows) is.
  static const int _itemCount = 12;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.xl),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _crossAxisCount,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: MediaCardSize.grid.aspectRatio!,
      ),
      itemCount: _itemCount,
      itemBuilder: (context, index) => SkeletonBlock(
        width: double.infinity,
        height: double.infinity,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
    );
  }
}
