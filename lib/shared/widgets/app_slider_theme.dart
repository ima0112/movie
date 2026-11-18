import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// The look of the app's range and value sliders (the year range, the max
/// duration): an amber track over `lineStrong`, white thumbs.
///
/// Flutter pads a slider's track by its overlay's radius (24 px by default),
/// which leaves the track narrower than everything above and below it. The
/// overlay here is as small as the thumb, so the track starts one thumb radius
/// in and each thumb's **outer edge** sits on the content's edge — lined up
/// with the cards and labels around it.
abstract final class AppSliderTheme {
  /// The thumb's radius, and the overlay's: the track's inset.
  static const double thumbRadius = 10;

  static SliderThemeData of(BuildContext context) =>
      SliderTheme.of(context).copyWith(
        activeTrackColor: AppColors.accent,
        inactiveTrackColor: AppColors.lineStrong,
        thumbColor: AppColors.ink,
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: thumbRadius,
        ),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: thumbRadius),
        overlayColor: AppColors.ink.withValues(alpha: 0.12),
      );
}
