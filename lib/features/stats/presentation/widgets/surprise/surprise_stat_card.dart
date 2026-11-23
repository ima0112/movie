import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';

/// The card every Surprise-me statistic sits on: `surfaceRaised`, the app's
/// card radius and padding, like C4's other cards.
class SurpriseStatCard extends StatelessWidget {
  const SurpriseStatCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}
