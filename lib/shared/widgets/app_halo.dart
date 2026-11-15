import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Fixed amber halo — `docs/DESIGN_SYSTEM.md` section 1 ("Halo"), used
/// behind Discover's header/hero (B1) and the Match hub's own Pako (B3).
/// `const`, built once: it never depends on load state (CLAUDE.md rule
/// 9).
///
/// Promoted from `features/discover/presentation/widgets/
/// discover_halo.dart` to `shared/widgets/` once `MatchHubSheet` (B3)
/// became this glow's second real consumer — `docs/SCREENS.md` itself
/// already treats the halo as a cross-screen design-system element
/// (B1, onboarding, F3/F3b all call for one), not a Discover-specific
/// effect.
///
/// TODO: SCREENS.md B1 also has this "fade with scrolling" — that needs
/// a `ScrollController` wired up from `DiscoverContentLoaded`'s
/// `ListView`, out of scope for this pass.
///
/// [intensity] scales how strong the glow is: `1` (the default) is Home's
/// halo; a smaller value fades its amber toward the page color (E1 uses a
/// softer one).
class AppHalo extends StatelessWidget {
  const AppHalo({super.key, this.intensity = 1});

  final double intensity;

  // No token or SCREENS.md literal fixes this — it's a rough "how far
  // down the glow reaches" placement, not a design-system dimension.
  static const double _height = 420;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        height: _height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.1,
              colors: [
                Color.lerp(
                  AppColors.surface,
                  AppColors.accentDeep,
                  intensity.clamp(0, 1),
                )!,
                AppColors.surface,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
