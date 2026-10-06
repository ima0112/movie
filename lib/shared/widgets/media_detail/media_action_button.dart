import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../app_buttons.dart';

/// One [MediaDetailActionRow] icon + its 12 px label — D1/D2 both use
/// this unchanged (`docs/SCREENS.md`). `caption` (11 px) is the closest
/// existing `AppTextStyles` token — there's no dedicated 12 px style yet
/// (CLAUDE.md rule 4). In its own file per rule 11:
/// `media_detail_action_row.dart` was over the 150-line target on its
/// own.
class MediaActionButton extends StatelessWidget {
  const MediaActionButton({
    super.key,
    required this.iconOutline,
    required this.iconFill,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData iconOutline;
  final IconData iconFill;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIconButton(
            iconOutline: iconOutline,
            iconFill: iconFill,
            isActive: isActive,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: isActive ? AppColors.accent : AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
