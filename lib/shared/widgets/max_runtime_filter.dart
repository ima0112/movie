import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/l10n_extension.dart';

/// The quiz's "max runtime" slider (no longer part of H8). Range/"No limit"
/// wording from A2's quiz step 4 ("'Max runtime' slider
/// (60–240 min, large number, 'No limit' at the far end)").
class MaxRuntimeFilter extends StatelessWidget {
  const MaxRuntimeFilter({
    super.key,
    required this.maxRuntimeMinutes,
    required this.onChanged,
  });

  final int? maxRuntimeMinutes;
  final ValueChanged<int?> onChanged;

  static const int _min = 60;
  static const int _max = 240;

  @override
  Widget build(BuildContext context) {
    final value = (maxRuntimeMinutes ?? _max).clamp(_min, _max);
    final isNoLimit = value >= _max;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isNoLimit
              ? context.l10n.discoverRangeFiltersNoLimit
              : context.l10n.discoverRangeFiltersMinutes(value),
          style: AppTextStyles.h3,
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.ink,
            inactiveTrackColor: AppColors.lineStrong,
            thumbColor: AppColors.ink,
          ),
          child: Slider(
            value: value.toDouble(),
            min: _min.toDouble(),
            max: _max.toDouble(),
            divisions: _max - _min,
            onChanged: (v) => onChanged(v.round() >= _max ? null : v.round()),
          ),
        ),
      ],
    );
  }
}
