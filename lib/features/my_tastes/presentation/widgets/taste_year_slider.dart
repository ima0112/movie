import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';

/// C5's "How far back" — "slider with a large number" (`docs/SCREENS.md`
/// C5), the same shape DESIGN_SYSTEM.md's own component sheet lists
/// generically ("Slider with a large number (year, runtime)").
///
/// Range: no doc gives an explicit min/max for "how far back"
/// specifically, so this reuses H8's own year range slider bound
/// instead of inventing a new one — `docs/SCREENS.md` H8: "year (range
/// slider 1950–present)".
///
/// Active track uses [AppColors.ink] (white), not the amber accent:
/// DESIGN_SYSTEM.md's closed list of where the accent is allowed
/// ("Dónde va el acento") doesn't mention sliders, and that section's
/// own rule is "if in doubt whether something should be amber, the
/// default answer is no" — white matches how primary interactive
/// emphasis is handled elsewhere (the primary button's own white pill).
class TasteYearSlider extends StatelessWidget {
  const TasteYearSlider({
    super.key,
    required this.yearFrom,
    required this.onChanged,
  });

  final int yearFrom;
  final ValueChanged<int> onChanged;

  static const int _minYear = 1950;

  @override
  Widget build(BuildContext context) {
    final maxYear = DateTime.now().year;
    final clamped = yearFrom.clamp(_minYear, maxYear);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.myTastesHowFarBackLabel, style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.sm),
        Text('$clamped', style: AppTextStyles.display),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.ink,
            inactiveTrackColor: AppColors.lineStrong,
            thumbColor: AppColors.ink,
            overlayColor: AppColors.ink.withValues(alpha: 0.12),
          ),
          child: Slider(
            value: clamped.toDouble(),
            min: _minYear.toDouble(),
            max: maxYear.toDouble(),
            divisions: maxYear - _minYear,
            onChanged: (value) => onChanged(value.round()),
          ),
        ),
      ],
    );
  }
}
