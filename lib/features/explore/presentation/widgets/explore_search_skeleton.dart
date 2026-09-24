import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/state_views.dart';

/// B2's "row skeleton" for State 2 while `MediaRepository.searchMulti`
/// resolves — shaped like `SearchResultsList`'s own row (56×84 poster +
/// two text lines).
class ExploreSearchSkeleton extends StatelessWidget {
  const ExploreSearchSkeleton({super.key});

  static const int _rowCount = 6;
  static const double _posterWidth = 56;
  static const double _posterHeight = 84;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.xl),
      itemCount: _rowCount,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, index) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBlock(
              width: _posterWidth,
              height: _posterHeight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonBlock(width: double.infinity, height: 16),
                    const SizedBox(height: AppSpacing.sm),
                    const SkeletonBlock(width: 120, height: 12),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
