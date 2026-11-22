import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/skeleton_block.dart';

/// A saved service's tile while the region's list loads: the same card
/// footprint as [TastePlatformTile], shimmering. Fills the grid cell.
class TastePlatformSkeleton extends StatelessWidget {
  const TastePlatformSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SkeletonBlock(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
    );
  }
}
