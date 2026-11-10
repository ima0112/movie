import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/l10n_extension.dart';

/// H2's date row: the chosen day in a bordered field with a calendar icon.
/// Tapping it opens the date picker (the parent's job — [onTap]).
class MarkAsWatchedDateField extends StatelessWidget {
  const MarkAsWatchedDateField({
    super.key,
    required this.date,
    required this.onTap,
  });

  final DateTime date;
  final VoidCallback onTap;

  static const double _height = 52;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(minHeight: _height),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised2,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat.yMMMd(context.l10n.localeName).format(date),
              style: AppTextStyles.body,
            ),
            const Icon(AppIcons.calendar, size: 20, color: AppColors.inkMuted),
          ],
        ),
      ),
    );
  }
}
