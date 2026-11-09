import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_buttons.dart';

/// I1 (Confirm deletion) — `docs/SCREENS.md` I1: "Cancel / Delete
/// (destructive)", opened from C6's "Delete My List"/"Delete My Tastes".
/// [title]/[body] arrive already composed (and already localized) by the
/// caller — a raw count/noun can't be interpolated into one generic
/// template and still agree in gender/number once translated.
///
/// A floating card with a red trash badge, the message, and Cancel /
/// Delete side by side (the "Ajustes · Confirmar borrado" design).
///
/// Returns `true` only if "Delete" was tapped; `false` for "Cancel" or
/// dismissing the dialog any other way (back gesture, tapping outside).
Future<bool> showConfirmDeletionDialog(
  BuildContext context, {
  required String title,
  required String body,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: AppColors.surfaceRaised2,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
        side: const BorderSide(color: AppColors.glassBorder),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _TrashBadge(),
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.sm),
            Text(
              body,
              style: AppTextStyles.body.copyWith(color: AppColors.inkMuted),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: context.l10n.commonCancel,
                    onTap: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: DestructiveButton(
                    label: context.l10n.commonDelete,
                    onTap: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return confirmed ?? false;
}

class _TrashBadge extends StatelessWidget {
  const _TrashBadge();

  static const double _size = 44;
  static const double _iconSize = 22;
  static const double _tint = 0.14;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.danger.withValues(alpha: _tint),
        ),
        child: const Icon(
          AppIcons.delete,
          size: _iconSize,
          color: AppColors.danger,
        ),
      ),
    );
  }
}
