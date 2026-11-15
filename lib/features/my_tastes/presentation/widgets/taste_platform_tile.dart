import 'package:flutter/material.dart';

import '../../../../core/domain/entities/streaming_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/streaming_service_logo.dart';

/// One of the user's streaming services in C5's "My platforms": its logo on a
/// neutral `surfaceRaised` card, with a small "×" at the corner — tapping the
/// tile takes the service off the list. Its accessibility label is "Remove
/// {name}" (the logo says the name visually).
///
/// Pure presentation — everything comes in by parameter.
class TastePlatformTile extends StatelessWidget {
  const TastePlatformTile({
    super.key,
    required this.service,
    required this.onRemove,
  });

  final StreamingService service;
  final VoidCallback onRemove;

  static const double _logoSize = 36;
  static const double _badgeSize = 18;
  static const double _badgeIcon = 12;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.l10n.myTastesPlatformRemove(service.name),
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onRemove,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.lineStrong),
                ),
                child: Center(
                  child: StreamingServiceLogo(
                    service: service,
                    size: _logoSize,
                  ),
                ),
              ),
            ),
            Positioned(
              top: AppSpacing.xs,
              right: AppSpacing.xs,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.surfaceRaised2,
                  shape: BoxShape.circle,
                ),
                child: const SizedBox(
                  width: _badgeSize,
                  height: _badgeSize,
                  child: Icon(
                    AppIcons.close,
                    size: _badgeIcon,
                    color: AppColors.inkMuted,
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
