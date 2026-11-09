import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/l10n_extension.dart';
import 'checkable_option_row.dart';

/// H5 (Language) — `docs/SCREENS.md` H5: "Single-select list: Español
/// / English." [selectedLanguageCode] is `AppSettings.languageCode`
/// (`es`/`en`) — now the single source for both TMDB content and the
/// app's own UI, so this is plain "Language" again, not "Content
/// language". [onSelected] is called with the new code and this sheet
/// pops itself — the caller never has to close it manually.
class LanguageSheet extends StatelessWidget {
  const LanguageSheet({
    super.key,
    required this.selectedLanguageCode,
    required this.onSelected,
  });

  final String selectedLanguageCode;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final options = [
      (code: 'es', label: l10n.languageNameSpanish),
      (code: 'en', label: l10n.languageNameEnglish),
    ];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.settingsLanguageLabel, style: AppTextStyles.h1),
            const SizedBox(height: AppSpacing.lg),
            for (final (i, option) in options.indexed) ...[
              if (i > 0) const Divider(height: 1),
              CheckableOptionRow(
                label: option.label,
                isSelected: option.code == selectedLanguageCode,
                onTap: () {
                  onSelected(option.code);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
