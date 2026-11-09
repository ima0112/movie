import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../state_views.dart';
import 'media_detail_header.dart';

/// D1/D2's loading state: "skeleton with the poster already visible via
/// the Hero and centered blocks" (`docs/SCREENS.md` D1) — a header-sized
/// block (the Hero transition already shows the real poster there) plus
/// a few centered text-line blocks standing in for title/metadata/rating.
class MediaDetailSkeleton extends StatelessWidget {
  const MediaDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        SkeletonBlock(
          width: width,
          height: MediaDetailHeader.height,
          borderRadius: BorderRadius.zero,
        ),
        const SizedBox(height: AppSpacing.sectionGap),
        Center(child: SkeletonBlock(width: width * 0.6, height: 28)),
        const SizedBox(height: AppSpacing.sm),
        Center(child: SkeletonBlock(width: width * 0.4, height: 16)),
        const SizedBox(height: AppSpacing.sectionGap),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: SkeletonBlock(width: width - AppSpacing.xl * 2, height: 52),
        ),
      ],
    );
  }
}
