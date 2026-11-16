import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// How a day is drawn, by how many titles were watched on it.
Color activityCellColor(int count) {
  if (count <= 0) return AppColors.surfaceRaised2;
  if (count == 1) return AppColors.accent.withValues(alpha: 0.35);
  if (count == 2) return AppColors.accent.withValues(alpha: 0.65);
  return AppColors.accent;
}

/// A calendar of the days from [start] to [end] (date-only, inclusive), each a
/// cell shaded by its count in [dayCounts] ([activityCellColor]). Days after
/// [today] are not drawn.
///
/// - **Dense** (all time, this year): weeks as columns, Monday at the top,
///   the cells sized to fill the width, with a caption over the first week of
///   each month ([monthLabel]).
/// - **Month** ([dense] false): a classic calendar — a Monday-first weekday
///   header and one row per week, the day number in each cell.
///
/// Pure presentation — everything comes in by parameter.
class ActivityCalendar extends StatelessWidget {
  const ActivityCalendar({
    super.key,
    required this.start,
    required this.end,
    required this.today,
    required this.dayCounts,
    required this.dense,
    this.monthLabelLength = 3,
  });

  final DateTime start;
  final DateTime end;
  final DateTime today;
  final Map<DateTime, int> dayCounts;
  final bool dense;

  /// How many letters of a month's name the dense layout writes (3, or 1 when
  /// the weeks are very narrow).
  final int monthLabelLength;

  static const double _gap = 2;
  static const double _maxDenseCell = 16;
  static const double _maxMonthCell = 40;

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  /// The Monday on or before [d].
  static DateTime mondayOf(DateTime d) =>
      DateTime(d.year, d.month, d.day - (d.weekday - DateTime.monday));

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    return dense ? _dense(locale) : _month(locale);
  }

  Widget _dense(String locale) {
    final gridStart = mondayOf(start);
    final columns = (_day(end).difference(gridStart).inDays ~/ 7) + 1;
    return LayoutBuilder(
      builder: (context, constraints) {
        final cell = ((constraints.maxWidth - _gap * (columns - 1)) / columns)
            .clamp(0.0, _maxDenseCell);
        final muted = AppTextStyles.micro.copyWith(color: AppColors.inkMuted);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: AppSpacing.lg,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  for (var c = 0; c < columns; c++)
                    if (_monthStartingIn(gridStart, c) case final month?)
                      Positioned(
                        left: c * (cell + _gap),
                        child: Text(
                          DateFormat.MMM(locale)
                              .format(month)
                              .substring(0, monthLabelLength)
                              .toUpperCase(),
                          style: muted,
                          softWrap: false,
                        ),
                      ),
                ],
              ),
            ),
            Row(
              children: [
                for (var c = 0; c < columns; c++) ...[
                  if (c > 0) const SizedBox(width: _gap),
                  Column(
                    children: [
                      for (var r = 0; r < 7; r++) ...[
                        if (r > 0) const SizedBox(height: _gap),
                        _cell(
                          DateTime(
                            gridStart.year,
                            gridStart.month,
                            gridStart.day + c * 7 + r,
                          ),
                          cell,
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }

  /// The month whose 1st falls in column [c], if any (to caption it).
  DateTime? _monthStartingIn(DateTime gridStart, int c) {
    for (var r = 0; r < 7; r++) {
      final d = DateTime(
        gridStart.year,
        gridStart.month,
        gridStart.day + c * 7 + r,
      );
      if (d.day == 1 && !d.isBefore(_day(start)) && !d.isAfter(_day(end))) {
        return d;
      }
    }
    return null;
  }

  Widget _month(String locale) {
    final gridStart = mondayOf(start);
    final rows = (_day(end).difference(gridStart).inDays ~/ 7) + 1;
    final muted = AppTextStyles.caption.copyWith(color: AppColors.inkMuted);
    // Monday-first narrow weekday names ("M", "T"…) in the user's language.
    final weekdays = [
      for (var i = 0; i < 7; i++)
        DateFormat.E(
          locale,
        ).format(DateTime(2024, 1, 1 + i)).characters.first.toUpperCase(),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final cell = ((constraints.maxWidth - _gap * 6) / 7).clamp(
          0.0,
          _maxMonthCell,
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                for (var i = 0; i < 7; i++) ...[
                  if (i > 0) const SizedBox(width: _gap),
                  SizedBox(
                    width: cell,
                    child: Text(
                      weekdays[i],
                      textAlign: TextAlign.center,
                      style: muted,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            for (var r = 0; r < rows; r++) ...[
              if (r > 0) const SizedBox(height: _gap),
              Row(
                children: [
                  for (var c = 0; c < 7; c++) ...[
                    if (c > 0) const SizedBox(width: _gap),
                    _cell(
                      DateTime(
                        gridStart.year,
                        gridStart.month,
                        gridStart.day + r * 7 + c,
                      ),
                      cell,
                      numbered: true,
                    ),
                  ],
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _cell(DateTime day, double size, {bool numbered = false}) {
    final inRange = !day.isBefore(_day(start)) && !day.isAfter(_day(end));
    if (!inRange || day.isAfter(_day(today))) {
      return SizedBox(width: size, height: size);
    }
    final count = dayCounts[day] ?? 0;
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: activityCellColor(count),
          borderRadius: BorderRadius.circular(
            numbered ? AppSpacing.radiusSm : AppSpacing.xxs,
          ),
        ),
        child: numbered
            ? Center(
                child: Text(
                  '${day.day}',
                  style: AppTextStyles.caption.copyWith(
                    color: count >= 3 ? AppColors.onAccent : AppColors.inkMuted,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
