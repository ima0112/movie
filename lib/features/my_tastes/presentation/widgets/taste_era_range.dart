import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// C5's "Eras" range: a two-handle slider over [minYear]–[maxYear] with the
/// chosen span in amber above it ("2000 – 2026") and the two bounds under it.
///
/// While a handle is dragged the span follows locally; [onChanged] is called
/// once, when the finger lifts, so a drag is one save and not hundreds.
///
/// Pure presentation — everything comes in by parameter.
class TasteEraRange extends StatefulWidget {
  const TasteEraRange({
    super.key,
    required this.from,
    required this.to,
    required this.minYear,
    required this.maxYear,
    required this.onChanged,
  });

  final int from;
  final int to;
  final int minYear;
  final int maxYear;
  final void Function(int from, int to) onChanged;

  @override
  State<TasteEraRange> createState() => _TasteEraRangeState();
}

class _TasteEraRangeState extends State<TasteEraRange> {
  RangeValues? _dragging;

  RangeValues get _values =>
      _dragging ??
      RangeValues(
        widget.from.clamp(widget.minYear, widget.maxYear).toDouble(),
        widget.to.clamp(widget.minYear, widget.maxYear).toDouble(),
      );

  @override
  Widget build(BuildContext context) {
    final values = _values;
    final muted = AppTextStyles.caption.copyWith(color: AppColors.inkMuted);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${values.start.round()} – ${values.end.round()}',
          textAlign: TextAlign.end,
          style: AppTextStyles.h3.copyWith(color: AppColors.accent),
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
              Text('${widget.maxYear}', style: muted),
            ],
          ),
        ),
      ],
    );
  }
}
