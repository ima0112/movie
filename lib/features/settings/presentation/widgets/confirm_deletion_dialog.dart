import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_buttons.dart';

/// I1 (Confirm deletion) — `docs/SCREENS.md` I1: "Cancel / Delete
/// (destructive)", opened from C6's "Delete My List"/"Delete My Tastes".
/// [itemCount] is folded into the body text, per C6's own instruction
/// that "the dialog states how many items it deletes" — [itemNoun] is
/// the singular form ("item", "selection"), pluralized here so callers
/// never have to.
///
/// Returns `true` only if "Delete" was tapped; `false` for "Cancel" or
/// dismissing the dialog any other way (back gesture, tapping outside).
Future<bool> showConfirmDeletionDialog(
  BuildContext context, {
  required String subject,
  required int itemCount,
  required String itemNoun,
}) async {
  final noun = itemCount == 1 ? itemNoun : '${itemNoun}s';
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surfaceRaised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      title: Text('Delete your $subject?', style: AppTextStyles.h3),
      content: Text(
        'This will remove $itemCount $noun. This can\'t be undone.',
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
          label: 'Cancel',
          fullWidth: false,
          onTap: () => Navigator.of(context).pop(false),
        ),
        const SizedBox(width: AppSpacing.sm),
        DestructiveButton(
          label: 'Delete',
          fullWidth: false,
          onTap: () => Navigator.of(context).pop(true),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
