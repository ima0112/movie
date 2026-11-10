import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_text_styles.dart';

/// One row of H5/H6 (Language/Region) — `docs/SCREENS.md`: "Sheets
/// H5–H7 are lists with an amber check on the active option; tapping
/// applies and closes." [onTap] is what actually applies the pick and
/// pops the sheet — this widget only renders the row (60 px, the selected
/// one in semibold); sheets put a hairline [Divider] between rows.
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

  static const double _minHeight = 60;
  static const double _checkSize = 22;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _minHeight),
          child: Row(
            children: [
              Expanded(
                child: Text(label, style: AppTextStyles.h3Toggle(isSelected)),
              ),
              if (isSelected)
                const Icon(
                  AppIcons.check,
                  color: AppColors.accent,
                  size: _checkSize,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
