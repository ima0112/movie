import 'package:flutter/widgets.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// "PakoTV", "Pako" in [AppColors.ink] + "TV" in [AppColors.accent].
///
/// Promoted from `discover_top_bar.dart` (B1's own top bar) once
/// `splash_screen.dart` (A1, "the wordmark slides into its spot on
/// Home" — `docs/SCREENS.md`) became its second real consumer; both need
/// the exact same mark so the splash's exit genuinely reads as landing
/// on Home's own.
class AppWordmark extends StatelessWidget {
  const AppWordmark({super.key, this.fontSize = 24});

  final double fontSize;

  // docs/SCREENS.md B1: "'PakoTV' wordmark at 24 px" — a one-off literal
  // for this specific brand mark (reuses h2's family/weight/line-height,
  // only the size is different), not a new entry in the general type
  // scale.
  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.h2.copyWith(fontSize: fontSize);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: 'Pako', style: style.copyWith(color: AppColors.ink)),
          TextSpan(text: 'TV', style: style.copyWith(color: AppColors.accent)),
        ],
      ),
    );
  }
}
