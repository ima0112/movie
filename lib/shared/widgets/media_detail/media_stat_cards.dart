import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// One label/value pair of [MediaStatCards].
class MediaStat {
  const MediaStat({required this.label, required this.value, this.onTap});

  final String label;
  final String value;

  /// A tappable stat (D2's "Seasons" → D2b): the card gets a chevron and the
  /// whole card is a button.
  final VoidCallback? onTap;
}

/// The two stat cards under the info card ("Duration" / "Classification"
/// in the "Detalle" design; D2's "Status" / "Seasons"): a small muted caption
/// over a bold value, side by side, a card with an `onTap` ending in a chevron. A stat with no value is simply not passed, and no stats means no
/// widget at all.
class MediaStatCards extends StatelessWidget {
  const MediaStatCards({super.key, required this.stats});

  final List<MediaStat> stats;

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenMargin,
        AppSpacing.cardGap,
        AppSpacing.screenMargin,
        0,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < stats.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.cardGap),
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
    final onTap = stat.onTap;
    final card = Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                // One line; a long value ("5 · 62 episodes" in a narrow card
                // at a large text size) ends in an ellipsis.
                Text(
                  stat.value,
                  style: AppTextStyles.h3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(
              AppIcons.chevronRight,
              size: 20,
              color: AppColors.inkMuted,
            ),
        ],
      ),
    );
    if (onTap == null) return card;
    return Semantics(
      button: true,
      excludeSemantics: true,
      label: '${stat.label} ${stat.value}',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: card,
      ),
    );
  }
}
