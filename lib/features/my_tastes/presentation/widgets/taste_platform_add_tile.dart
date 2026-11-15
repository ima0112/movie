import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';

/// The last cell of C5's "My platforms" grid: a tile the size of a platform's,
/// on `surface` with a dashed-looking hairline (the "suggestion" look of the
/// chips), a "+" and "Add" — so adding sits in the grid, where the services
/// are, instead of floating under it.
///
/// Pure presentation — what it does is [onTap]'s business.
class TastePlatformAddTile extends StatelessWidget {
  const TastePlatformAddTile({super.key, required this.onTap});

  final VoidCallback onTap;

  static const double _icon = 20;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.l10n.myTastesPlatformsAdd,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.lineStrong),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(AppIcons.add, size: _icon, color: AppColors.ink),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  context.l10n.myTastesPlatformsAdd,
                  style: AppTextStyles.bodySm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
