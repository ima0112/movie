import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';

/// The platforms step's "All platforms" row: a card with the label and a
/// switch that is **on exactly while no service is picked** (it carries no
/// state of its own). Picking a service turns it off; taking the last one out
/// turns it back on; tapping it while off clears the picks. Tapping it while on
/// does nothing — the way out is to pick a service.
///
/// Pure presentation — everything comes in by parameter.
class QuizAllPlatformsRow extends StatelessWidget {
  const QuizAllPlatformsRow({
    super.key,
    required this.allSelected,
    required this.onSelectAll,
  });

  /// No service picked.
  final bool allSelected;

  /// Called when the switch is turned on (only possible while it is off).
  final VoidCallback onSelectAll;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.lineStrong),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.cardPadding,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.quizPlatformAll,
                style: AppTextStyles.bodySm,
              ),
            ),
            Switch(
              value: allSelected,
              // Turning it on clears the picks; turning it off by hand is not
              // a thing (there would be nothing picked and not "all").
              onChanged: (on) {
                if (on) onSelectAll();
              },
              activeThumbColor: AppColors.onAccent,
              activeTrackColor: AppColors.accent,
            ),
          ],
        ),
      ),
    );
  }
}
