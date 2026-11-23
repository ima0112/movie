import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/still_image.dart';

/// The top of the episode sheet: the 16:9 still **edge to edge**, fading into
/// the sheet's colour at its foot, the sheet's drag handle drawn over it, and
/// the episode's code ("T1 · E1") in a dark pill at its lower left.
///
/// The sheet is opened with its own handle turned off (`showDragHandle: false`)
/// so this one can sit on the image instead of above it.
class EpisodeSheetHeader extends StatelessWidget {
  const EpisodeSheetHeader({
    super.key,
    required this.stillPath,
    required this.code,
  });

  final String? stillPath;

  /// Already localized ("T1 · E1", "Especiales · E1").
  final String code;

  static const double _handleWidth = 40;
  static const double _handleHeight = 4;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppSpacing.bottomSheetRadius,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            StillImage(stillPath: stillPath),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.4, 1],
                  colors: [
                    AppColors.surfaceRaised.withValues(alpha: 0),
                    AppColors.surfaceRaised,
                  ],
                ),
              ),
            ),
            Positioned(
              top: AppSpacing.sm,
              left: 0,
              right: 0,
              child: Center(
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
            Positioned(
              left: AppSpacing.xl,
              bottom: AppSpacing.md,
              child: _CodePill(label: code),
            ),
          ],
        ),
      ),
    );
  }
}

/// The dark pill with the episode code. Fixed to the text scale 1: it is a tag
/// over an image.
class _CodePill extends StatelessWidget {
  const _CodePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withNoTextScaling(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
        child: Text(label, style: AppTextStyles.bodySmStrong),
      ),
    );
  }
}
