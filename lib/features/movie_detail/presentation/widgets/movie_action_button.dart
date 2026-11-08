import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_buttons.dart';

/// One [MovieActionRow] icon + its 12 px label (SCREENS.md D1). `caption`
/// (11 px) is the closest existing `AppTextStyles` token — there's no
/// dedicated 12 px style yet (CLAUDE.md rule 4). In its own file per rule
/// 11: `movie_action_row.dart` was over the 150-line target on its own.
class MovieActionButton extends StatelessWidget {
  const MovieActionButton({
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
