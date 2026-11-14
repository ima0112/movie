import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/results_grid.dart';
import '../../../../shared/widgets/state_views.dart';

/// C1's "grid skeleton" — the same 3-column shape as `FilteredListGrid`
/// itself (a poster and a line for its title), filled with [SkeletonBlock]s.
class FilteredListGridSkeleton extends StatelessWidget {
  const FilteredListGridSkeleton({super.key});

  // Four full rows — no data to size this by yet, so it's a fixed count
  // the same way `FilteredListCubit.pageSize` (also four rows) is.
  static const int _itemCount = 12;

  static const double _titleHeight = 12;

  @override
  Widget build(BuildContext context) {
    final caption = ResultsGrid.captionExtent(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth - AppSpacing.screenMargin * 2;
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenMargin,
            AppSpacing.lg,
            AppSpacing.screenMargin,
            AppSpacing.xl,
          ),
          gridDelegate: ResultsGrid.delegate(width, captionExtent: caption),
          itemCount: _itemCount,
          itemBuilder: (context, index) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SkeletonBlock(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const SkeletonBlock(width: double.infinity, height: _titleHeight),
            ],
          ),
        );
      },
    );
  }
}
