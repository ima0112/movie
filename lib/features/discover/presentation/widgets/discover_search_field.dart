import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';

/// A search-field look-alike under the hero: a shortcut to B2's real field —
/// tapping it opens Explore with that field already focused and the keyboard
/// up. `docs/SCREENS.md` B1.
class DiscoverSearchField extends StatelessWidget {
  const DiscoverSearchField({super.key});

  static const double _height = 48;

  @override
  Widget build(BuildContext context) {
    final hint = context.l10n.exploreSearchHint;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Semantics(
        button: true,
        label: hint,
        excludeSemantics: true,
        child: GestureDetector(
          onTap: () => context.go(AppRoutes.exploreSearch()),
          child: Container(
            height: _height,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: [
                const Icon(AppIcons.search, color: AppColors.inkMuted),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    hint,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.inkMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
