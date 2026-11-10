import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// The warm glow rising from the bottom edge, behind the intro slides and
/// the "Make it yours" step ([child] sits on top).
class OnboardingGlowBackground extends StatelessWidget {
  const OnboardingGlowBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.bottomCenter,
          radius: 1.1,
          colors: [AppColors.accentDeep, AppColors.surface],
          stops: [0, 0.7],
        ),
      ),
      child: child,
    );
  }
}
