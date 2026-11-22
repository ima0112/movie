import 'package:flutter/material.dart';

import '../../../../../core/domain/stats/surprise_insights.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../l10n/genre_localization.dart';
import '../../../../../l10n/l10n_extension.dart';
import 'surprise_stat_card.dart';

/// "New to you": chosen cards with a genre the user had not watched or
/// favorited before — the title, which genres were new, and the rating once
/// watched.
class SurpriseDiscoveriesCard extends StatelessWidget {
  const SurpriseDiscoveriesCard({super.key, required this.discoveries});

  final List<SurpriseDiscovery> discoveries;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SurpriseStatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.statsSurpriseNewHint,
            style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
          ),
          for (final d in discoveries)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.title, style: AppTextStyles.bodySmStrong),
                        Text(
                          l10n.statsSurpriseNewGenres(
                            d.newGenres
                                .map((g) => g.localizedName(l10n))
                                .join(', '),
                          ),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (d.rating != null) ...[
                    const SizedBox(width: AppSpacing.md),
                    Text('${d.rating}', style: AppTextStyles.bodySmStrong),
                    const SizedBox(width: AppSpacing.xs),
                    const Icon(
                      AppIcons.starFill,
                      size: AppSpacing.lg,
                      color: AppColors.accent,
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
