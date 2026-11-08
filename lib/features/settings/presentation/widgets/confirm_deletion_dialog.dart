import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
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
/// Returns `true` only if "Delete" was tapped; `false` for "Cancel" or
/// dismissing the dialog any other way (back gesture, tapping outside).
Future<bool> showConfirmDeletionDialog(
  BuildContext context, {
  required String title,
  required String body,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surfaceRaised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      title: Text(title, style: AppTextStyles.h3),
      content: Text(
        body,
        style: AppTextStyles.body.copyWith(color: AppColors.inkMuted),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      actions: [
        TextLinkButton(
          label: context.l10n.commonCancel,
          fullWidth: false,
          onTap: () => Navigator.of(context).pop(false),
        ),
        const SizedBox(width: AppSpacing.sm),
        DestructiveButton(
          label: context.l10n.commonDelete,
          fullWidth: false,
          onTap: () => Navigator.of(context).pop(true),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
