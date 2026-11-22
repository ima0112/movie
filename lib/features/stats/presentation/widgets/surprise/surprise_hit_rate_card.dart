import 'package:flutter/material.dart';

import '../../../../../core/domain/stats/surprise_insights.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../l10n/l10n_extension.dart';
import 'surprise_stat_card.dart';

/// "Does it work for me?": the share of sessions that ended with a chosen
/// card in large type, the counts under it, and how many rounds ("other 5")
/// it took to decide.
class SurpriseHitRateCard extends StatelessWidget {
  const SurpriseHitRateCard({super.key, required this.hitRate});

  final SurpriseHitRate hitRate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final percent = (hitRate.rate * 100).round();
    final buckets = hitRate.batchesToChoose;
    return SurpriseStatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.statsGenrePercent(percent),
            style: AppTextStyles.display.copyWith(color: AppColors.accent),
          ),
          Text(
            l10n.statsSurpriseHitRateCaption,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${l10n.statsSurpriseSessions(hitRate.sessions)} · '
            '${l10n.statsSurprisePicks(hitRate.chosenSessions)}',
            style: AppTextStyles.bodySmStrong,
          ),
          if (hitRate.savedOnlySessions > 0) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.statsSurpriseSavedOnly(hitRate.savedOnlySessions),
              style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
            ),
          ],
          if (hitRate.chosenSessions > 0) ...[
            const SizedBox(height: AppSpacing.xl),
            Text(l10n.statsSurpriseBatchTitle, style: AppTextStyles.bodySm),
            const SizedBox(height: AppSpacing.md),
            _Bar(
              label: l10n.statsSurpriseBatchFirst,
              count: buckets[1] ?? 0,
              total: hitRate.chosenSessions,
            ),
            _Bar(
              label: l10n.statsSurpriseBatchSecond,
              count: buckets[2] ?? 0,
              total: hitRate.chosenSessions,
            ),
            _Bar(
              label: l10n.statsSurpriseBatchThird,
              count: buckets[3] ?? 0,
              total: hitRate.chosenSessions,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.statsSurpriseBatchAverage(
                hitRate.averageBatchesToChoose!.toStringAsFixed(1),
              ),
              style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
            ),
          ],
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.label, required this.count, required this.total});

  final String label;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption,
            ),
          ),
          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : count / total,
                minHeight: AppSpacing.xs,
                color: AppColors.accent,
                backgroundColor: AppColors.surfaceRaised2,
              ),
            ),
          ),
          SizedBox(
            width: AppSpacing.xxl,
            child: Text(
              '$count',
              textAlign: TextAlign.end,
              style: AppTextStyles.captionStrong,
            ),
          ),
        ],
      ),
    );
  }
}
