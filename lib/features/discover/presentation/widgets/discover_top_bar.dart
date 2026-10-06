import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_wordmark.dart';

/// "PakoTV" wordmark + search icon. `const`, built once: static structure
/// per `docs/SCREENS.md` B1 ("Top bar... Nothing else") — never depends
/// on load state (CLAUDE.md rule 9).
class DiscoverTopBar extends StatelessWidget {
  const DiscoverTopBar({super.key});

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
          const AppWordmark(),
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
