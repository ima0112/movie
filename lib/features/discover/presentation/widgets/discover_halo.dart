import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Fixed amber halo behind the header and hero top — see
/// `docs/DESIGN_SYSTEM.md` section 1 ("Halo"). `const`, built once: it
/// never depends on load state (CLAUDE.md rule 9).
///
/// TODO: SCREENS.md B1 also has this "fade with scrolling" — that needs a
/// `ScrollController` wired up from `DiscoverContentLoaded`'s `ListView`,
/// out of scope for this pass.
class DiscoverHalo extends StatelessWidget {
  const DiscoverHalo({super.key});

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
              colors: [AppColors.accentDeep, AppColors.surface],
            ),
          ),
        ),
      ),
    );
  }
}
