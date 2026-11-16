import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'actions_sheet_row.dart';

/// One choice of an [ActionsSheet].
class SheetAction {
  const SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;

  /// Runs after the sheet has closed.
  final VoidCallback onTap;
  final bool destructive;
}

/// A bottom sheet of actions for one item: its [leading] picture (a poster, or
/// a person's round photo), [title] and muted [subtitle] on top, then one
/// [ActionsSheetRow] per [SheetAction]. Tapping an action closes the sheet and
/// then runs it, so it can open another sheet from the caller's context.
///
/// Open it with [ActionsSheet.show].
class ActionsSheet extends StatelessWidget {
  const ActionsSheet({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.actions,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final List<SheetAction> actions;

  static const double _leadingWidth = 62;
  static const double _leadingHeight = 92;

  static Future<void> show(
    BuildContext context, {
    required Widget leading,
    required String title,
    required String subtitle,
    required List<SheetAction> actions,
  }) async {
    final chosen = await showModalBottomSheet<SheetAction>(
      context: context,
      builder: (_) => ActionsSheet(
        leading: leading,
        title: title,
        subtitle: subtitle,
        actions: actions,
      ),
    );
    chosen?.onTap();
  }

  /// A poster-shaped slot for [ActionsSheet.leading]: [child] rounded, or the
  /// placeholder color without one.
  static Widget posterSlot(Widget? child) => ClipRRect(
    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
    child: SizedBox(
      width: _leadingWidth,
      height: _leadingHeight,
      child: child ?? const ColoredBox(color: AppColors.surfaceRaised2),
    ),
  );

  /// A round slot (a person's photo), as wide as the poster slot.
  static Widget roundSlot(Widget child) => SizedBox(
    width: _leadingWidth,
    height: _leadingWidth,
    child: ClipOval(child: child),
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                leading,
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.h2,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          subtitle,
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.inkMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final (i, action) in actions.indexed)
              ActionsSheetRow(
                icon: action.icon,
                label: action.label,
                destructive: action.destructive,
                showDivider: i < actions.length - 1,
                onTap: () => Navigator.of(context).pop(action),
              ),
          ],
        ),
      ),
    );
  }
}
