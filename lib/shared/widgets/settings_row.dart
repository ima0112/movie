import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// One row of C6 (Settings)'s grouped list — `docs/SCREENS.md` C6: "52 px
/// row, 16 px white label, 15 px gray value, chevron; no icons or group
/// backgrounds". Shared by every C6 section (Data, About, and — once
/// built — Preferences), not feature-specific.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.label,
    this.value,
    this.labelColor,
    this.showChevron = true,
    this.onTap,
    this.onLongPress,
  });

  final String label;
  final String? value;

  /// Overrides the label's color — e.g. [AppColors.danger] for "Delete
  /// My List"/"Delete My Tastes" (`docs/SCREENS.md` C6: "in red").
  final Color? labelColor;

  final bool showChevron;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: SizedBox(
        height: 52,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.body.copyWith(
                    color: labelColor ?? AppColors.ink,
                  ),
                ),
              ),
              if (value != null) ...[
                Text(
                  value!,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              if (showChevron)
                const Icon(
                  AppIcons.chevronRight,
                  size: 16,
                  color: AppColors.inkMuted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// C6's "13 px gray group header" — e.g. "Preferences", "Data", "About".
class SettingsGroupHeader extends StatelessWidget {
  const SettingsGroupHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.sm,
      ),
      child: Text(
        title,
        style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
      ),
    );
  }
}
