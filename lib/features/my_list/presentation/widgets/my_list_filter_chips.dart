import 'package:flutter/material.dart';

import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_chip.dart';
import '../cubit/my_list_cubit.dart';

/// H9's Type and Sort chip rows, split out of `my_list_filter_sheet.dart`
/// per CLAUDE.md rule 11. Pure presentation — no `MyListCubit` dependency;
/// the sheet owns the draft `TabFilter` and passes each row its value.
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

/// H9: "Type (All/Movies/TV Shows)".
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

/// H9's sort chips. [options] is the caller's already-filtered list for
/// the current tab (`my_list_filter_sheet` decides which `MyListSort`
/// values apply — myRating/dateWatched are Watched-only).
class SortFilterChips extends StatelessWidget {
  const SortFilterChips({
    super.key,
    required this.options,
    required this.sort,
    required this.onChanged,
  });

  final List<MyListSort> options;
  final MyListSort sort;
  final ValueChanged<MyListSort> onChanged;

  static const _labels = {
    MyListSort.recent: 'Recent',
    MyListSort.titleAZ: 'Title A–Z',
    MyListSort.year: 'Year',
    MyListSort.tmdbRating: 'TMDB rating',
    MyListSort.myRating: 'My rating',
    MyListSort.dateWatched: 'Date watched',
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final option in options)
          AppChip(
            label: _labels[option]!,
            state: option == sort ? ChipState.selected : ChipState.normal,
            onTap: () => onChanged(option),
          ),
      ],
    );
  }
}
