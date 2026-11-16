import 'package:flutter/material.dart';

import '../../../../core/domain/entities/streaming_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/streaming_service_logo.dart';

/// One streaming service of C5's "My platforms": its logo on a neutral
/// `surfaceRaised` card; picked = an amber ring and a small amber check at the
/// corner. The name is the accessibility label (the logo says it visually).
///
/// Pure presentation — everything comes in by parameter.
class TastePlatformTile extends StatelessWidget {
  const TastePlatformTile({
    super.key,
    required this.service,
    required this.selected,
    required this.onTap,
  });

  final StreamingService service;
  final bool selected;
  final VoidCallback onTap;

  static const double _logoSize = 36;
  static const double _checkSize = 18;
  static const double _checkIcon = 12;
  static const double _selectedTint = 0.12;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: service.name,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.accent.withValues(alpha: _selectedTint)
                      : AppColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: selected ? AppColors.accent : AppColors.lineStrong,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Center(
                  child: StreamingServiceLogo(
                    service: service,
                    size: _logoSize,
                  ),
                ),
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
                    width: _checkSize,
                    height: _checkSize,
                    child: Icon(
                      AppIcons.check,
                      size: _checkIcon,
                      color: AppColors.onAccent,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
