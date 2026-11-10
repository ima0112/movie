import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';

/// D2's "Seasons · 5 (62 ep.)" card — the entry to D2b (the "Detalle serie"
/// design's Temporadas card). A bordered `surfaceRaised` box with a small
/// muted label, a semibold value and a chevron.
class TvSeasonsLinkCard extends StatelessWidget {
  const TvSeasonsLinkCard({
    super.key,
    required this.seasonCount,
    required this.episodeCount,
    required this.onTap,
  });

  final int seasonCount;
  final int episodeCount;
  final VoidCallback onTap;

  static const double _minHeight = 72;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenMargin,
        AppSpacing.cardGap,
        AppSpacing.screenMargin,
        0,
      ),
      child: Semantics(
        button: true,
        excludeSemantics: true,
        label:
            '${l10n.tvSeasonsLinkLabel} '
            '${l10n.tvSeasonsLinkValue(seasonCount, episodeCount)}',
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            constraints: const BoxConstraints(minHeight: _minHeight),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
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
                        l10n.tvSeasonsLinkLabel,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.inkMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.tvSeasonsLinkValue(seasonCount, episodeCount),
                        style: AppTextStyles.h2,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  AppIcons.chevronRight,
                  size: 20,
                  color: AppColors.inkMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
