import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';

/// The back button every pushed screen gets, in D1's "back circle (60%
/// black) top left" treatment (`docs/SCREENS.md` D1) — generalized here
/// since SCREENS.md's own navigation rule applies to every pushed screen,
/// not just D1: "Every pushed screen... has a back button" (SCREENS.md,
/// top-level navigation rule).
///
/// Drop it directly into a `Stack` with no `Positioned` wrapper needed —
/// [Align] keeps it a fixed 40 px circle top left regardless of the
/// `Stack`'s `fit` (in particular `StackFit.expand`, which would
/// otherwise stretch a plain non-positioned child to fill the whole
/// `Stack`), and [SafeArea] + padding keeps it clear of the status
/// bar/notch even when a sibling (e.g. a full-bleed poster) extends
/// behind it.
///
/// Pure presentation — no feature dependency, everything comes in by
/// parameter (there are none: it always pops the current route).
class ScrimBackButton extends StatelessWidget {
  const ScrimBackButton({super.key});

  // "Not a brand color, so it isn't part of AppColors" — same reasoning
  // as media_card.dart's own `_scrim` (the poster tag/save button).
  static const Color scrim = Color(0x99000000);
  static const double diameter = 40;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: SafeArea(
        child: Padding(
          // Lines up with the screen's content margin.
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenMargin,
            vertical: AppSpacing.lg,
          ),
          child: GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: diameter,
              height: diameter,
              decoration: const BoxDecoration(
                color: scrim,
                shape: BoxShape.circle,
              ),
              child: const Icon(AppIcons.back, color: AppColors.ink, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}
