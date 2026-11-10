import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// One label/value pair of [MediaStatCards].
class MediaStat {
  const MediaStat({required this.label, required this.value});

  final String label;
  final String value;
}

/// D1's two stat cards under the info card ("Duration" / "Classification"
/// in the "Detalle" design): a small muted caption over a bold value, side by
/// side. A stat with no value is simply not passed, and no stats means no
/// widget at all.
class MediaStatCards extends StatelessWidget {
  const MediaStatCards({super.key, required this.stats});

  final List<MediaStat> stats;

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        0,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < stats.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.md),
              Expanded(child: _StatCard(stat: stats[i])),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});

  final MediaStat stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stat.label,
            style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(stat.value, style: AppTextStyles.h3),
        ],
      ),
    );
  }
}
