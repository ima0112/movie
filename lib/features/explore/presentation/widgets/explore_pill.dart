import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// One pill of B2's Genre / Platform rows: outlined when off, amber when
/// selected (the same look as `AppChip`), with an optional [leading] widget —
/// a platform's logo. 40 px tall so it is an easy touch target.
class ExplorePill extends StatelessWidget {
  const ExplorePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.leading,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? leading;

  static const double height = 40;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      excludeSemantics: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          constraints: const BoxConstraints(minHeight: height),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          decoration: BoxDecoration(
            color: selected ? AppColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            border: selected ? null : Border.all(color: AppColors.lineStrong),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(
                label,
                style: AppTextStyles.bodySmToggle(selected).copyWith(
                  color: selected ? AppColors.onAccent : AppColors.ink,
                ),
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
