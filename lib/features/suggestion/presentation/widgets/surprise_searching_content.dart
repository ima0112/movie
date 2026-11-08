import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/state_views.dart';

/// E3's own "loading (card skeleton with 'Searching…' text)".
class SurpriseSearchingContent extends StatelessWidget {
  const SurpriseSearchingContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your suggestion', style: AppTextStyles.h1),
        const SizedBox(height: AppSpacing.xl),
        AspectRatio(
          aspectRatio: 2 / 3,
          child: SkeletonBlock(
            width: double.infinity,
            height: double.infinity,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Searching…',
          style: AppTextStyles.body.copyWith(color: AppColors.inkMuted),
        ),
      ],
    );
  }
}
