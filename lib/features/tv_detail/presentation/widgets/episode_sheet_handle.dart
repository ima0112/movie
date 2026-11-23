import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// The episode sheet's drag handle, drawn over the still, and the strip around
/// it that closes the sheet when it is pulled down.
///
/// The sheet is opened with its own handle turned off (`showDragHandle:
/// false`) so this one can sit on the image instead of above it. It lives
/// **outside the scrolling content**, on top of it: a swipe that starts here
/// reaches the sheet's own drag (the content's list would otherwise take every
/// vertical swipe, and the sheet would never close).
class EpisodeSheetHandle extends StatelessWidget {
  const EpisodeSheetHandle({super.key});

  /// The height of the strip that takes the swipe.
  static const double height = 48;
  static const double _handleWidth = 40;
  static const double _handleHeight = 4;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: GestureDetector(
        // Opaque, so the strip takes the touch away from the list behind it
        // and leaves it to the sheet's own drag recognizer above.
        behavior: HitTestBehavior.opaque,
        onTap: () {},
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Container(
              width: _handleWidth,
              height: _handleHeight,
              decoration: BoxDecoration(
                color: AppColors.sheetHandle,
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
