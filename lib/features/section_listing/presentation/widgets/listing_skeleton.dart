import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/media_card.dart';
import '../../../../shared/widgets/state_views.dart';

/// The grid while the first page is on its way: four rows of poster blocks.
class ListingSkeleton extends StatelessWidget {
  const ListingSkeleton({super.key});

  static const int _count = 12;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.screenMargin),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: MediaCardSize.grid.aspectRatio!,
      ),
      itemCount: _count,
      itemBuilder: (context, index) => SkeletonBlock(
        width: double.infinity,
        height: double.infinity,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
    );
  }
}
