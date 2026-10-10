import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';

/// E2 step 4's "'Max seasons' stepper (1–10, 'No limit')"
/// (`docs/SCREENS.md` E2). No reusable stepper existed yet —
/// `docs/DESIGN_SYSTEM.md` section 5's own component sheet lists one
/// ("9. Stepper (seasons) and toggle"), but it hadn't been built before
/// this. `null` ("No limit") sits past 10, the same "unset lives at the
/// far end of the range" convention `MaxRuntimeFilter`'s own slider
/// already uses.
///
/// Pure presentation — no feature dependency, everything comes in by
/// parameter. Kept in `quiz/presentation/widgets/` rather than
/// `shared/widgets/`: nothing else needs a seasons stepper yet — same
/// "promote once a second real consumer exists" bar this codebase
/// applies elsewhere.
class MaxSeasonsStepper extends StatelessWidget {
  const MaxSeasonsStepper({
    super.key,
    required this.maxSeasons,
    required this.onChanged,
  });

  final int? maxSeasons;
  final ValueChanged<int?> onChanged;

  static const int _min = 1;
  static const int _max = 10;

  // docs/SCREENS.md doesn't give this a fixed width — wide enough for
  // "No limit" without the +/- buttons jumping around as the number's
  // digit count changes.
  static const double _valueWidth = 72;

  void _decrement() {
    final current = maxSeasons;
    if (current == null) {
      onChanged(_max);
    } else if (current > _min) {
      onChanged(current - 1);
    }
  }

  void _increment() {
    final current = maxSeasons;
    if (current == null) return; // already "No limit"
    onChanged(current >= _max ? null : current + 1);
  }

  @override
  Widget build(BuildContext context) {
    final current = maxSeasons;
    final canDecrement = current == null || current > _min;
    final canIncrement = current != null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(context.l10n.quizMaxSeasonsLabel, style: AppTextStyles.body),
        Row(
          children: [
            IconButton(
              icon: Icon(
                AppIcons.stepperDecrement,
                color: canDecrement ? AppColors.ink : AppColors.inkDim,
              ),
              onPressed: canDecrement ? _decrement : null,
            ),
            SizedBox(
              width: _valueWidth,
              child: Text(
                current == null
                    ? context.l10n.discoverRangeFiltersNoLimit
                    : '$current',
                textAlign: TextAlign.center,
                style: AppTextStyles.h3,
              ),
            ),
            IconButton(
              icon: Icon(
                AppIcons.stepperIncrement,
                color: canIncrement ? AppColors.ink : AppColors.inkDim,
              ),
              onPressed: canIncrement ? _increment : null,
            ),
          ],
        ),
      ],
    );
  }
}
