import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// The top row of Surprise me's deck and closing screens: a "×" on the left
/// and the centred accent [title] eyebrow (a spacer of the button's width on
/// the right keeps it centred). Static: nothing in it ever rebuilds.
class SurpriseDeckTopBar extends StatelessWidget {
  const SurpriseDeckTopBar({
    super.key,
    required this.title,
    required this.onClose,
  });

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: IconButton(
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            icon: const Icon(AppIcons.close, color: AppColors.ink),
            onPressed: onClose,
          ),
        ),
        Expanded(
          child: Text(
            title.toUpperCase(),
            textAlign: TextAlign.center,
            style: AppTextStyles.overline.copyWith(color: AppColors.accent),
          ),
        ),
        const SizedBox(width: kMinInteractiveDimension + 2 * AppSpacing.sm),
      ],
    );
  }
}
