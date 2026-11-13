import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// The one grid layout of lists of results across the app — the filtered
/// results (C1) and every "See all" (C1b): **three columns** of 2:3 posters on
/// the page margin, [gap] apart ([rowGap] between rows). A tile may carry a caption under its poster
/// (C1's title); [delegate] adds room for it.
class ResultsGrid {
  const ResultsGrid._();

  static const int columns = 3;
  static const double gap = AppSpacing.md;

  /// The space between rows — more than between columns: a row's caption
  /// needs air before the next poster starts.
  static const double rowGap = AppSpacing.xl;

  /// The width one column takes in a grid [availableWidth] wide (the page
  /// margins already taken out).
  static double columnWidth(double availableWidth) =>
      (availableWidth - gap * (columns - 1)) / columns;

  /// The height of the caption under a poster — the title (one line) and the
  /// release year (one line) with the gap above them — at the current text
  /// scale, so a larger text setting grows the cell instead of overflowing it.
  static double captionExtent(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    double line(TextStyle style) =>
        scaler.scale(style.fontSize! * style.height!).ceilToDouble();
    // Plus a pixel each: text layout rounds a line's height, and a half-pixel
    // short would overflow the tile.
    return AppSpacing.sm +
        line(AppTextStyles.bodySm) +
        1 +
        line(AppTextStyles.caption) +
        1;
  }

  /// The grid delegate for a grid [availableWidth] wide whose tiles are a 2:3
  /// poster plus [captionExtent] pixels under it (0 for a bare poster).
  static SliverGridDelegate delegate(
    double availableWidth, {
    double captionExtent = 0,
  }) {
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
      mainAxisSpacing: rowGap,
      crossAxisSpacing: gap,
      mainAxisExtent: columnWidth(availableWidth) * 3 / 2 + captionExtent,
    );
  }
}
