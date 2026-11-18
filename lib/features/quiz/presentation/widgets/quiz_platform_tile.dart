import 'package:flutter/material.dart';

import '../../../../core/domain/entities/streaming_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/streaming_service_logo.dart';

/// One streaming service of the quiz's platforms step (E2 step 3): its logo on
/// a neutral card with its name under it. Selected: an amber tint and hairline
/// and a check badge on the corner. Tapping toggles it.
///
/// Pure presentation — everything comes in by parameter.
class QuizPlatformTile extends StatelessWidget {
  const QuizPlatformTile({
    super.key,
    required this.service,
    required this.selected,
    required this.onTap,
  });

  final StreamingService service;
  final bool selected;
  final VoidCallback onTap;

  static const double _logoSize = 40;

  /// The name's line height at the default text size (`captionStrong`).
  static const double _nameLine = 18;

  /// The tile's height for the user's text size: logo, gap, the name's line
  /// and the padding — so a larger text grows the tile instead of overflowing.
  static double heightFor(BuildContext context) =>
      AppSpacing.md * 2 +
      _logoSize +
      AppSpacing.sm +
      MediaQuery.textScalerOf(context).scale(_nameLine);
  static const double _badgeSize = 18;
  static const double _badgeIcon = 12;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: service.name,
      excludeSemantics: true,
      child: Material(
        color: selected ? AppColors.accentSoft : AppColors.surfaceRaised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: BorderSide(
            color: selected ? AppColors.accentLine : AppColors.lineStrong,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.md,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StreamingServiceLogo(service: service, size: _logoSize),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      service.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.captionStrong,
                    ),
                  ],
                ),
              ),
              if (selected)
                Positioned(
                  top: AppSpacing.xs,
                  right: AppSpacing.xs,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox(
                      width: _badgeSize,
                      height: _badgeSize,
                      child: Icon(
                        AppIcons.check,
                        size: _badgeIcon,
                        color: AppColors.onAccent,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
