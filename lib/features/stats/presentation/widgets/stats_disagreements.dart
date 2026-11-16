import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/router.dart';
import '../../../../core/domain/stats/library_insights.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';

/// The titles the user rated furthest from TMDB (up to three): title and
/// "You ★ 5 · TMDB ★ 3.2". Each opens the detail.
class StatsDisagreements extends StatelessWidget {
  const StatsDisagreements({super.key, required this.disagreements});

  final List<RatingDisagreement> disagreements;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fmt = NumberFormat('0.0', Localizations.localeOf(context).toString());
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.statsDisagreementsTitle, style: AppTextStyles.bodyStrong),
            for (final d in disagreements)
              InkWell(
                onTap: () => context.pushMediaDetail(d.entry.key),
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          d.entry.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySm,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        l10n.statsDisagreement(
                          '${d.userStars}',
                          fmt.format(d.tmdbStars),
                        ),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
