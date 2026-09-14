import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// "PakoTV" wordmark + search icon. `const`, built once: static structure
/// per `docs/SCREENS.md` B1 ("Top bar... Nothing else") — never depends
/// on load state (CLAUDE.md rule 9).
class DiscoverTopBar extends StatelessWidget {
  const DiscoverTopBar({super.key});

  // docs/SCREENS.md B1: "'PakoTV' wordmark at 24 px" — a one-off literal
  // for this specific brand mark (reuses h2's family/weight/line-height,
  // only the size is different), not a new entry in the general type
  // scale.
  static final TextStyle _wordmarkStyle = AppTextStyles.h2.copyWith(
    fontSize: 24,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Pako',
                  style: _wordmarkStyle.copyWith(color: AppColors.ink),
                ),
                TextSpan(
                  text: 'TV',
                  style: _wordmarkStyle.copyWith(color: AppColors.accent),
                ),
              ],
            ),
          ),
          IconButton(
            // TODO: → B2 (Explore) with the field focused, once go_router
            // and B2 exist.
            onPressed: () {},
            icon: const Icon(AppIcons.search, color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}
