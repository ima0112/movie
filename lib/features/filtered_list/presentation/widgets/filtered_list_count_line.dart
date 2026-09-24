import 'package:flutter/material.dart';

import '../../../../core/domain/entities/discover_filter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// C1's "line '312 results · Popularity'" (`docs/SCREENS.md` C1) — the
/// true total (`FilteredListLoaded.totalCount`), not how much the grid
/// has revealed so far.
class FilteredListCountLine extends StatelessWidget {
  const FilteredListCountLine({
    super.key,
    required this.count,
    required this.sortBy,
  });

  final int count;
  final DiscoverSortBy sortBy;

  static const _sortLabels = {
    DiscoverSortBy.popularity: 'Popularity',
    DiscoverSortBy.rating: 'Rating',
    DiscoverSortBy.releaseDate: 'Date',
    DiscoverSortBy.title: 'Title',
  };

  @override
  Widget build(BuildContext context) {
    return Text(
      '$count results · ${_sortLabels[sortBy]}',
      style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
    );
  }
}
