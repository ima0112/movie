import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_buttons.dart';

/// Compact inline error, matching `docs/SCREENS.md` B1's per-section
/// error style literally ("90 px row 'Couldn't load · Retry'") — no Pako
/// here, that's reserved for empty/cold-start states elsewhere on this
/// screen (see B1: "This is the only place in Home where Pako appears",
/// referring to the cold-start invitation card, not a load error).
///
/// Used today for the *whole* content area, because `DiscoverCubit` loads
/// hero+sections atomically — a real failure fails everything at once.
/// Once sections can fail independently, this same widget is what a
/// per-section error would show for just its own section.
class DiscoverContentError extends StatelessWidget {
  const DiscoverContentError({super.key, required this.onRetry});

  final VoidCallback onRetry;

  // Literal from docs/SCREENS.md ("90 px row"), not an AppSpacing token —
  // a fixed size of this one component.
  static const double _height = 90;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Couldn't load",
              style: AppTextStyles.body.copyWith(color: AppColors.inkMuted),
            ),
            const SizedBox(width: AppSpacing.sm),
            TextLinkButton(label: 'Retry', onTap: onRetry, fullWidth: false),
          ],
        ),
      ),
    );
  }
}
