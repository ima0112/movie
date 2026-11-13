import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/l10n_extension.dart';
import 'filter_section_header.dart';

/// H8's two numeric-range controls — the years and the rating
/// (`docs/SCREENS.md` H8). Each is a section header with its live value on the
/// right, a slider with a white thumb and an amber active track (as in the
/// mockups) and the two ends' values under it.
///
/// Both report `null` when they are back at their resting position (the
/// whole range / no minimum), so "nothing is set" is one value, not a
/// range that happens to cover everything.

SliderThemeData _sliderTheme(BuildContext context) =>
    SliderTheme.of(context).copyWith(
      activeTrackColor: AppColors.accent,
      inactiveTrackColor: AppColors.lineStrong,
      thumbColor: AppColors.ink,
      overlayColor: AppColors.accent.withValues(alpha: 0.16),
    );

class _EndLabels extends StatelessWidget {
  const _EndLabels(this.start, this.end);

  final String start;
  final String end;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.caption.copyWith(color: AppColors.inkMuted);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(start, style: style),
          Text(end, style: style),
        ],
      ),
    );
  }
}

/// "Years": a range slider from [minYear] to the current year.
class YearRangeFilter extends StatelessWidget {
  const YearRangeFilter({
    super.key,
    required this.yearFrom,
    required this.yearTo,
    required this.onChanged,
  });

  final int? yearFrom;
  final int? yearTo;

  /// Both `null` when the slider covers the whole range.
  final void Function(int? yearFrom, int? yearTo) onChanged;

  static const int minYear = 1950;

  @override
  Widget build(BuildContext context) {
    final maxYear = DateTime.now().year;
    final from = (yearFrom ?? minYear).clamp(minYear, maxYear);
    final to = (yearTo ?? maxYear).clamp(minYear, maxYear);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilterSectionHeader(
          context.l10n.filterSheetSectionYear,
          trailing: Text(
            context.l10n.discoverRangeFiltersYearRange(from, to),
            style: AppTextStyles.h3,
          ),
        ),
        SliderTheme(
          data: _sliderTheme(context),
          child: RangeSlider(
            values: RangeValues(from.toDouble(), to.toDouble()),
            min: minYear.toDouble(),
            max: maxYear.toDouble(),
            divisions: maxYear - minYear,
            onChanged: (values) {
              final start = values.start.round();
              final end = values.end.round();
              final whole = start == minYear && end == maxYear;
              onChanged(whole ? null : start, whole ? null : end);
            },
          ),
        ),
        _EndLabels('$minYear', '$maxYear'),
      ],
    );
  }
}

/// "Rating": a range slider from 0 to 10 in half points; `vote_count.gte`
/// stays fixed (`DiscoverFilter.minVoteCount`), so a title with three 10s
/// never passes.
class RatingRangeFilter extends StatelessWidget {
  const RatingRangeFilter({
    super.key,
    required this.minVoteAverage,
    required this.maxVoteAverage,
    required this.onChanged,
  });

  final double? minVoteAverage;
  final double? maxVoteAverage;

  /// Each end is `null` while it is at its limit (0 / 10).
  final void Function(double? min, double? max) onChanged;

  static const double max = 10;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final low = minVoteAverage ?? 0;
    final high = maxVoteAverage ?? max;
    final whole = low == 0 && high == max;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilterSectionHeader(
          l10n.filterSheetSectionRating,
          trailing: whole
              ? Text(l10n.filterSheetMinRatingAny, style: AppTextStyles.h3)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      AppIcons.starFill,
                      size: AppSpacing.lg,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      l10n.filterSheetRatingRangeValue(
                        low.toStringAsFixed(1),
                        high.toStringAsFixed(1),
                      ),
                      style: AppTextStyles.h3,
                    ),
                  ],
                ),
        ),
        SliderTheme(
          data: _sliderTheme(context),
          child: RangeSlider(
            values: RangeValues(low, high),
            min: 0,
            max: max,
            divisions: (max * 2).round(),
            onChanged: (values) => onChanged(
              values.start == 0 ? null : values.start,
              values.end == max ? null : values.end,
            ),
          ),
        ),
        _EndLabels('0', '${max.round()}'),
      ],
    );
  }
}
