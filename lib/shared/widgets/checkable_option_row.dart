import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// One row of H5/H6 (Language/Region) — `docs/SCREENS.md`: "Sheets
/// H5–H7 are lists with an amber check on the active option; tapping
/// applies and closes." [onTap] is what actually applies the pick and
/// pops the sheet — this widget only renders the row.
class CheckableOptionRow extends StatelessWidget {
  const CheckableOptionRow({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            Expanded(child: Text(label, style: AppTextStyles.body)),
            if (isSelected)
              const Icon(AppIcons.check, color: AppColors.accent, size: 20),
          ],
        ),
      ),
    );
  }
}
