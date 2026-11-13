import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../l10n/l10n_extension.dart';
import 'app_chip.dart';
import 'filter_section_header.dart';
import 'original_language_catalog.dart';

/// H8's "Original language" row: "Any" and [originalLanguages], single select,
/// one line that scrolls sideways.
class FilterLanguageChips extends StatelessWidget {
  const FilterLanguageChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  /// The picked language's ISO 639-1 code, or `null` for any.
  final String? selected;
  final ValueChanged<String?> onChanged;

  static const double _rowHeight = 40;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final options = <(String?, String)>[
      (null, l10n.filterSheetLanguageAny),
      for (final (code, name) in originalLanguages) (code, name),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilterSectionHeader(l10n.filterSheetSectionLanguage),
        SizedBox(
          height: _rowHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: options.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final (code, label) = options[index];
              return Center(
                child: AppChip(
                  label: label,
                  state: code == selected
                      ? ChipState.selected
                      : ChipState.normal,
                  onTap: () => onChanged(code),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
