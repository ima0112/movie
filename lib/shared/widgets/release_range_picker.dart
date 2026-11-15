import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/l10n_extension.dart';
import 'app_chip.dart';
import 'year_bound_card.dart';
import 'year_histogram.dart';

/// A release-year range picker: "FROM" and "TO" cards with the chosen years
/// ("2010", "Today"), a histogram of [counts] with the chosen span in amber,
/// a two-handle slider, and the presets All · 2020s · 2010s · Earlier.
///
/// While a handle is dragged the cards, bars and handles follow locally;
/// [onChanged] is called once, when the finger lifts (or a preset is tapped),
/// so a drag is one save and not hundreds. A [to] of [maxYear] reads "Today".
///
/// Pure presentation — everything comes in by parameter.
class ReleaseRangePicker extends StatefulWidget {
  const ReleaseRangePicker({
    super.key,
    required this.from,
    required this.to,
    required this.minYear,
    required this.maxYear,
    required this.counts,
    required this.onChanged,
  });

  final int from;
  final int to;
  final int minYear;

  /// The latest year (this year): the range's open end, shown as "Today".
  final int maxYear;

  /// The histogram's buckets (see `yearBuckets`, 2 years each).
  final List<int> counts;
  final void Function(int from, int to) onChanged;

  @override
  State<ReleaseRangePicker> createState() => _ReleaseRangePickerState();
}

class _ReleaseRangePickerState extends State<ReleaseRangePicker> {
  RangeValues? _dragging;

  RangeValues get _values =>
      _dragging ??
      RangeValues(
        widget.from.clamp(widget.minYear, widget.maxYear).toDouble(),
        widget.to.clamp(widget.minYear, widget.maxYear).toDouble(),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final values = _values;
    final from = values.start.round();
    final to = values.end.round();
    String year(int y) => y >= widget.maxYear ? l10n.releaseRangeToday : '$y';
    final muted = AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted);
    final presets = [
      (l10n.releaseRangeAll, widget.minYear, widget.maxYear),
      (l10n.releaseRange2020s, 2020, widget.maxYear),
      (l10n.releaseRange2010s, 2010, 2019),
      (l10n.releaseRangeEarlier, widget.minYear, 2009),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: YearBoundCard(
                label: l10n.releaseRangeFrom,
                value: year(from),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text('–', style: AppTextStyles.h2),
            ),
            Expanded(
              child: YearBoundCard(label: l10n.releaseRangeTo, value: year(to)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        YearHistogram(
          counts: widget.counts,
          minYear: widget.minYear,
          from: from,
          to: to,
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.accent,
            inactiveTrackColor: AppColors.lineStrong,
            thumbColor: AppColors.ink,
            overlayColor: AppColors.ink.withValues(alpha: 0.12),
          ),
          child: RangeSlider(
            values: values,
            min: widget.minYear.toDouble(),
            max: widget.maxYear.toDouble(),
            divisions: widget.maxYear - widget.minYear,
            onChanged: (next) => setState(() => _dragging = next),
            onChangeEnd: (next) {
              setState(() => _dragging = null);
              widget.onChanged(next.start.round(), next.end.round());
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${widget.minYear}', style: muted),
              Text(l10n.releaseRangeToday, style: muted),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final (label, presetFrom, presetTo) in presets)
              AppChip(
                label: label,
                state: from == presetFrom && to == presetTo
                    ? ChipState.selected
                    : ChipState.normal,
                onTap: () {
                  setState(() => _dragging = null);
                  widget.onChanged(presetFrom, presetTo);
                },
              ),
          ],
        ),
      ],
    );
  }
}
