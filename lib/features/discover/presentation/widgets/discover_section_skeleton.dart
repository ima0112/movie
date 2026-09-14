import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/media_card.dart';
import '../../../../shared/widgets/state_views.dart';

/// One section's skeleton: a title-shaped block, then a row of
/// carousel-poster-shaped blocks. Shared by `DiscoverContentSkeleton` (the
/// very first load) and `DiscoverSectionCarousel` (a section that hasn't
/// arrived yet, once sections can load independently) — that reuse is why
/// this needs its own file rather than living inside either of them.
class DiscoverSectionSkeleton extends StatelessWidget {
  const DiscoverSectionSkeleton({super.key});

  static const int _posterCount = 3;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonBlock(width: 140, height: 20),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: MediaCardSize.carousel.height,
          child: Row(
            children: [
              for (var i = 0; i < _posterCount; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.md),
                SkeletonBlock(
                  width: MediaCardSize.carousel.width,
                  height: MediaCardSize.carousel.height,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
