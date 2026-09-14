import 'package:flutter/material.dart';

import '../../../../core/domain/entities/media_segment.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/media_card.dart';
import '../../../../shared/widgets/state_views.dart';
import '../bloc/discover_cubit.dart';
import 'discover_section_skeleton.dart';

/// Skeleton for the whole content area — the hero plus one
/// [DiscoverSectionSkeleton] per section [segment] has, so switching
/// segments immediately shows the right *shape* of skeleton even before
/// `DiscoverCubit.sectionsBySegment` data arrives.
class DiscoverContentSkeleton extends StatelessWidget {
  const DiscoverContentSkeleton({super.key, required this.segment});

  final MediaSegment segment;

  @override
  Widget build(BuildContext context) {
    final sectionCount = DiscoverCubit.sectionsBySegment[segment]!.length;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: LayoutBuilder(
            builder: (context, constraints) => SkeletonBlock(
              width: constraints.maxWidth,
              height: MediaCardSize.hero.height,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),
        for (var i = 0; i < sectionCount; i++) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: DiscoverSectionSkeleton(),
          ),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ],
    );
  }
}
