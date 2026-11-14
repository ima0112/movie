import 'package:flutter/material.dart';

import '../../core/domain/entities/discover_filter.dart';
import '../../core/domain/entities/discover_preset.dart';
import '../../core/domain/entities/media_type.dart';
import '../../core/theme/app_spacing.dart';
import '../../l10n/discover_preset_localization.dart';
import '../../l10n/discover_sort_by_localization.dart';
import '../../l10n/l10n_extension.dart';
import 'app_chip.dart';

/// H8's "Sort by": the four plain orders ([options] — Popular, Top rated,
/// Newest, Oldest) followed by the presets of the kind of title
/// ([DiscoverPreset.forType]: Coming soon and In theaters for movies,
/// Finished and Airing now for shows, none for All). One choice among them
/// all: a preset is a slice of the catalog ordered by popularity, so picking
/// one replaces the order and picking an order drops the preset.
///
/// Distinct from My List's own `SortFilterChips` (a different enum).
///
/// Pure presentation — everything comes in by parameter.
class DiscoverSortChips extends StatelessWidget {
  const DiscoverSortChips({
    super.key,
    required this.type,
    required this.sortBy,
    required this.preset,
    required this.onSortChanged,
    required this.onPresetChanged,
  });

  final MediaType? type;
  final DiscoverSortBy sortBy;
  final DiscoverPreset? preset;
  final ValueChanged<DiscoverSortBy> onSortChanged;
  final ValueChanged<DiscoverPreset> onPresetChanged;

  static const List<DiscoverSortBy> options = [
    DiscoverSortBy.popularity,
    DiscoverSortBy.rating,
    DiscoverSortBy.releaseDate,
    DiscoverSortBy.releaseDateAsc,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final option in options)
          AppChip(
            label: option.sheetLabel(l10n),
            state: preset == null && option == sortBy
                ? ChipState.selected
                : ChipState.normal,
            onTap: () => onSortChanged(option),
          ),
        for (final option in DiscoverPreset.forType(type))
          AppChip(
            label: option.localizedLabel(l10n),
            state: option == preset ? ChipState.selected : ChipState.normal,
            onTap: () => onPresetChanged(option),
          ),
      ],
    );
  }
}
