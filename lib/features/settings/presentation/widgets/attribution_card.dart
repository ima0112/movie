import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// One provider block on C7: a name chip, the attribution line, and a
/// gray line saying what the data is used for.
///
/// [providerName] is a brand name (TMDB, JustWatch) — never translated.
class AttributionCard extends StatelessWidget {
  const AttributionCard({
    super.key,
    required this.providerName,
    required this.body,
    required this.detail,
  });

  final String providerName;
  final String body;
  final String detail;

  static const double _chipHeight = 32;
  static const double _chipLetterSpacing = 1;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: _chipHeight,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised2,
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              ),
              child: Text(
                providerName,
                style: AppTextStyles.bodySmStrong.copyWith(
                  letterSpacing: _chipLetterSpacing,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(body, style: AppTextStyles.body),
            const SizedBox(height: AppSpacing.md),
            Text(
              detail,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
            ),
          ],
        ),
      ),
    );
  }
}
