import 'package:flutter/material.dart';
import 'overline_label.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// One row of C6 (Settings)'s grouped list — `docs/SCREENS.md` C6: 56 px
/// row, 16 px white label, gray value, chevron; no icons. Always lives
/// inside a [SettingsGroup]. Shared by every C6 section, not
/// feature-specific.
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

  static const double _height = 56;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: SizedBox(
        height: _height,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    color: labelColor ?? AppColors.ink,
                  ),
                ),
              ),
              if (value != null) ...[
                Flexible(
                  child: Text(
                    value!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.inkMuted,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              if (showChevron)
                const Icon(
                  AppIcons.chevronRight,
                  size: 20,
                  color: AppColors.inkMuted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One C6 group: a small spaced-out gray header over a rounded
/// `surfaceRaised` card holding [children] (usually [SettingsRow]s),
/// separated by hairline dividers — the "Ajustes" design.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: OverlineLabel(title),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: ColoredBox(
              color: AppColors.surfaceRaised,
              child: Column(
                children: [
                  for (var i = 0; i < children.length; i++) ...[
                    if (i > 0)
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.line,
                      ),
                    children[i],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
