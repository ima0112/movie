import 'package:flutter/material.dart';

import '../../core/domain/entities/media_type.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_chip.dart';

/// A filter sheet's small gray section label — e.g. H9's "Type", "Sort
/// by", H8's own sections. Promoted out of My List's own
/// `my_list_filter_chips.dart` once H8 needed the exact same label
/// style, rather than duplicate it.
///
/// Pure presentation — no feature dependency, everything comes in by
/// parameter.
class FilterSectionLabel extends StatelessWidget {
  const FilterSectionLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        label,
        style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
      ),
    );
  }
}

/// "Type (All/Movies/TV Shows)" — H9 and H8 both have this exact chip
/// row (`docs/SCREENS.md` H8/H9). Promoted for the same reason as
/// [FilterSectionLabel]: identical in both, not just similar.
///
/// Pure presentation — no feature dependency, everything comes in by
/// parameter.
class TypeFilterChips extends StatelessWidget {
  const TypeFilterChips({
    super.key,
    required this.type,
    required this.onChanged,
  });

  final MediaType? type;
  final ValueChanged<MediaType?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      children: [
        _chip(context, 'All', null),
        _chip(context, 'Movies', MediaType.movie),
        _chip(context, 'TV Shows', MediaType.tvShow),
      ],
    );
  }

  Widget _chip(BuildContext context, String label, MediaType? value) {
    return AppChip(
      label: label,
      state: value == type ? ChipState.selected : ChipState.normal,
      onTap: () => onChanged(value),
    );
  }
}
