import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/pako_state.dart';

/// E2 step 3 — `docs/SCREENS.md` E2: "How far back do you want to go?":
/// large year number, full-width slider (1950–present), room for an
/// illustration."
///
/// The "illustration" slot is Pako reacting to the year — no Rive
/// runtime is wired up yet (`docs/DECISIONS.md` section 9), so this uses
/// the static [PakoState] placeholder `PakoState`'s own file already
/// documents with a `// TODO(rive)`, rather than adding a second one
/// here.
///
/// Slider styling (ink track, no accent) matches every other slider in
/// this codebase (`TasteYearSlider`, H8's `YearRangeFilter`/
/// `MinRatingFilter`/`MaxRuntimeFilter`) — repeated per-widget there
/// too, not a shared component, so this doesn't invent a new exception.
class QuizYearStep extends StatelessWidget {
  const QuizYearStep({
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
        Text('How far back do you want to go?', style: AppTextStyles.h1),
        const SizedBox(height: AppSpacing.xl),
        const Center(child: PakoState(mood: PakoMood.idle)),
        const SizedBox(height: AppSpacing.xl),
        Center(child: Text('$clamped', style: AppTextStyles.display)),
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
