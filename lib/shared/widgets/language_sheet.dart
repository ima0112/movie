import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'checkable_option_row.dart';

/// H5 (Language) — `docs/SCREENS.md` H5: "Single-select list: Español /
/// English." [selectedLanguageCode] is `AppSettings.languageCode`
/// (`es`/`en`); [onSelected] is called with the new code and this sheet
/// pops itself — the caller never has to close it manually.
class LanguageSheet extends StatelessWidget {
  const LanguageSheet({
    super.key,
    required this.selectedLanguageCode,
    required this.onSelected,
  });

  final String selectedLanguageCode;
  final ValueChanged<String> onSelected;

  static const _options = [
    (code: 'es', label: 'Español'),
    (code: 'en', label: 'English'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Language', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.md),
            for (final option in _options)
              CheckableOptionRow(
                label: option.label,
                isSelected: option.code == selectedLanguageCode,
                onTap: () {
                  onSelected(option.code);
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}
