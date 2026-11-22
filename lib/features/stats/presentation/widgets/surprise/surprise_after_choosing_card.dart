import 'package:flutter/material.dart';

import '../../../../../core/domain/stats/surprise_insights.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../l10n/l10n_extension.dart';
import 'surprise_stat_card.dart';
import 'surprise_stat_row.dart';

/// "What happened to what I chose?": how many of the chosen cards were watched
/// and which are still waiting in Watch later, the average rating, and the
/// best-rated ones.
class SurpriseAfterChoosingCard extends StatelessWidget {
  const SurpriseAfterChoosingCard({super.key, required this.after});

  final SurpriseAfterChoosing after;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SurpriseStatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.statsTitlesCount(after.chosen), style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            child: LinearProgressIndicator(
              value: after.watchedRate,
              minHeight: AppSpacing.xs,
              color: AppColors.accent,
              backgroundColor: AppColors.surfaceRaised2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SurpriseStatRow(
            label: l10n.statsSurpriseWatched,
            value: SurpriseStatValue(
              l10n.statsSurpriseOfTotal(after.watched, after.chosen),
            ),
          ),
          if (after.stillInWatchLater > 0)
            SurpriseStatRow(
              label: l10n.statsSurpriseWaiting,
              value: SurpriseStatValue('${after.stillInWatchLater}'),
            ),
          if (after.averageRating != null)
            SurpriseStatRow(
              label: l10n.statsSurpriseAverageRating,
              value: _Stars(text: after.averageRating!.toStringAsFixed(1)),
            ),
          if (after.best.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.statsSurpriseBestTitle, style: AppTextStyles.bodySm),
            const SizedBox(height: AppSpacing.xs),
            for (final title in after.best)
              SurpriseStatRow(
                label: title.title,
                value: _Stars(text: '${title.rating}'),
              ),
          ],
        ],
      ),
    );
  }
}

/// A rating: the number and a filled star.
class _Stars extends StatelessWidget {
  const _Stars({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text, style: AppTextStyles.bodySmStrong),
        const SizedBox(width: AppSpacing.xs),
        const Icon(
          AppIcons.starFill,
          size: AppSpacing.lg,
          color: AppColors.accent,
        ),
      ],
    );
  }
}
