import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// H8's three numeric-range controls — year range, minimum rating, and
/// max runtime (`docs/SCREENS.md` H8). Grouped in one file: each is a
/// small labeled slider over a fixed numeric range, not substantial
/// enough on its own to need separate files under CLAUDE.md rule 11.
///
/// All three use [AppColors.ink] (white) for the active track, not
/// amber — matching `TasteYearSlider`'s own reasoning: DESIGN_SYSTEM.md's
/// closed accent-usage list doesn't mention sliders, and its own rule is
/// "if in doubt, the default is no".

/// H8: "year (range slider 1950–present)" — reuses `TasteYearSlider`'s
/// own 1950 lower bound for the same reason it picked it (H8 itself is
/// where that literal bound comes from).
class YearRangeFilter extends StatelessWidget {
  const YearRangeFilter({
    super.key,
    required this.yearFrom,
    required this.yearTo,
    required this.onChanged,
  });

  final int? yearFrom;
  final int? yearTo;
  final void Function(int yearFrom, int yearTo) onChanged;

  static const int minYear = 1950;

  @override
  Widget build(BuildContext context) {
    final maxYear = DateTime.now().year;
    final from = (yearFrom ?? minYear).clamp(minYear, maxYear);
    final to = (yearTo ?? maxYear).clamp(minYear, maxYear);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$from – $to', style: AppTextStyles.h3),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.ink,
            inactiveTrackColor: AppColors.lineStrong,
            thumbColor: AppColors.ink,
          ),
          child: RangeSlider(
            values: RangeValues(from.toDouble(), to.toDouble()),
            min: minYear.toDouble(),
            max: maxYear.toDouble(),
            divisions: maxYear - minYear,
            onChanged: (values) =>
                onChanged(values.start.round(), values.end.round()),
          ),
        ),
      ],
    );
  }
}

/// H8: "minimum rating (0–9 slider, `vote_count.gte=100` fixed)" — the
/// `vote_count.gte` part is a hard-coded TMDB query parameter a real
/// `MediaRepositoryImpl` always sends alongside this, not something the
/// UI (or `DiscoverFilter`) exposes as a user-adjustable value.
class MinRatingFilter extends StatelessWidget {
  const MinRatingFilter({
    super.key,
    required this.minVoteAverage,
    required this.onChanged,
  });

  final double? minVoteAverage;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final value = minVoteAverage ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value.toStringAsFixed(1), style: AppTextStyles.h3),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.ink,
            inactiveTrackColor: AppColors.lineStrong,
            thumbColor: AppColors.ink,
          ),
          child: Slider(
            value: value,
            min: 0,
            max: 9,
            divisions: 18,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

/// H8: "max runtime (movies only)". Range/"No limit" wording matches
/// A2's own quiz step 4 for the identical control ("'Max runtime' slider
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
        Text(isNoLimit ? 'No limit' : '$value min', style: AppTextStyles.h3),
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
