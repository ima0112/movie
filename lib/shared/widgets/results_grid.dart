import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// The one grid layout of lists of results across the app — the filtered
/// results (C1) and every "See all" (C1b): **three columns** of 2:3 posters on
/// the page margin, [gap] apart. A tile may carry a caption under its poster
/// (C1's title); [delegate] adds room for it.
class ResultsGrid {
  const ResultsGrid._();

  static const int columns = 3;
  static const double gap = AppSpacing.md;

  /// The width one column takes in a grid [availableWidth] wide (the page
  /// margins already taken out).
  static double columnWidth(double availableWidth) =>
      (availableWidth - gap * (columns - 1)) / columns;

  /// The height of a one-line caption under a poster: its gap plus the line
  /// at the current text scale, so a larger text setting grows the cell
  /// instead of overflowing it.
  static double captionExtent(BuildContext context) {
    final style = AppTextStyles.bodySm;
    final line = MediaQuery.textScalerOf(
      context,
    ).scale(style.fontSize! * style.height!);
    // Rounded up, plus a pixel: text layout rounds the line's height, and a
    // half-pixel short would overflow the tile.
    return AppSpacing.sm + line.ceilToDouble() + 1;
  }

  /// The grid delegate for a grid [availableWidth] wide whose tiles are a 2:3
  /// poster plus [captionExtent] pixels under it (0 for a bare poster).
  static SliverGridDelegate delegate(
    double availableWidth, {
    double captionExtent = 0,
  }) {
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
      mainAxisSpacing: gap,
      crossAxisSpacing: gap,
      mainAxisExtent: columnWidth(availableWidth) * 3 / 2 + captionExtent,
    );
  }
}
