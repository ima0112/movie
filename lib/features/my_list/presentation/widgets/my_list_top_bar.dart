import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';

/// B4's top bar: the "My List" title (`docs/SCREENS.md` B4). The filter icon
/// that used to sit at its end is gone for now (H9 isn't offered).
class MyListTopBar extends StatelessWidget {
  const MyListTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      child: SizedBox(
        // The bar's height with the icon it had, so the page doesn't shift.
        height: kMinInteractiveDimension,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(context.l10n.navTabMyList, style: AppTextStyles.h2),
        ),
      ),
    );
  }
}
