import 'package:flutter/material.dart';

import '../../../../core/domain/entities/discover_filter.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_chip.dart';

/// H8: "sort by Popularity/Rating/Date/Title" (`docs/SCREENS.md` H8).
/// Distinct from My List's own `SortFilterChips` (a different enum,
/// `MyListSort` — recency/title/year/rating for a *library*, not a
/// catalog search) rather than shared with it.
///
/// Pure presentation — no feature dependency, everything comes in by
/// parameter.
class DiscoverSortChips extends StatelessWidget {
  const DiscoverSortChips({
    super.key,
    required this.sortBy,
    required this.onChanged,
  });

  final DiscoverSortBy sortBy;
  final ValueChanged<DiscoverSortBy> onChanged;

  static const _labels = {
    DiscoverSortBy.popularity: 'Popularity',
    DiscoverSortBy.rating: 'Rating',
    DiscoverSortBy.releaseDate: 'Date',
    DiscoverSortBy.title: 'Title',
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final option in DiscoverSortBy.values)
          AppChip(
            label: _labels[option]!,
            state: option == sortBy ? ChipState.selected : ChipState.normal,
            onTap: () => onChanged(option),
          ),
      ],
    );
  }
}
