import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import 'overline_label.dart';

/// The label row of one block of the filter sheet (H8): the section's name in
/// small spaced capitals on the left and, when there is one, a [trailing]
/// widget on the right — the live value of a slider, the region of the
/// streaming row.
///
/// Pure presentation — everything comes in by parameter.
class FilterSectionHeader extends StatelessWidget {
  const FilterSectionHeader(this.label, {super.key, this.trailing});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(child: OverlineLabel(label)),
          ?trailing,
        ],
      ),
    );
  }
}
