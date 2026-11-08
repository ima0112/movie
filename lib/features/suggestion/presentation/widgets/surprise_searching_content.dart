import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/state_views.dart';

/// E3's own "loading (card skeleton with 'Searching…' text)".
class SurpriseSearchingContent extends StatelessWidget {
  const SurpriseSearchingContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.surpriseYourSuggestionTitle, style: AppTextStyles.h1),
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
          context.l10n.surpriseSearchingLabel,
          style: AppTextStyles.body.copyWith(color: AppColors.inkMuted),
        ),
      ],
    );
  }
}
