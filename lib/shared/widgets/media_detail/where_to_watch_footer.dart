import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/l10n_extension.dart';
import 'justwatch_badge.dart';

/// The Where-to-watch card's foot when there are services: "Tap a service to
/// open it in JustWatch" with the mandatory "Data from JustWatch" under it as
/// its subtitle, both at the left, and the [JustWatchBadge] at the right, level
/// with the first line.
class WhereToWatchFooter extends StatelessWidget {
  const WhereToWatchFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return MergeSemantics(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.whereToWatchTapHint,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                const WhereToWatchAttribution(),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const JustWatchBadge(),
        ],
      ),
    );
  }
}

/// The mandatory "Data from JustWatch" line (small, dim).
class WhereToWatchAttribution extends StatelessWidget {
  const WhereToWatchAttribution({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      context.l10n.whereToWatchJustWatchAttribution,
      style: AppTextStyles.caption.copyWith(color: AppColors.inkDim),
    );
  }
}
