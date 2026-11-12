import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/listing_sort_localization.dart';
import '../../../../shared/widgets/checkable_option_row.dart';
import '../../domain/listing_source.dart';

/// The sheet behind the sort icon: a single-select list of [options] with an
/// amber check on [selected]; tapping applies and closes (like H5–H7).
class ListingSortSheet extends StatelessWidget {
  const ListingSortSheet({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<ListingSort> options;
  final ListingSort selected;
  final ValueChanged<ListingSort> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      // Five rows and a title don't fit a small phone's sheet: scroll.
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.sectionListingSortTitle, style: AppTextStyles.h1),
            const SizedBox(height: AppSpacing.lg),
            for (final (i, sort) in options.indexed) ...[
              if (i > 0) const Divider(height: 1),
              CheckableOptionRow(
                label: sort.localizedLabel(l10n),
                isSelected: sort == selected,
                onTap: () {
                  onSelected(sort);
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
