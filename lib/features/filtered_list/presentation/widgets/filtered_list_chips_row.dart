import 'package:flutter/material.dart';

import '../../../../core/domain/entities/discover_filter.dart';
import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_chip.dart';

/// C1's "row of active filter chips, each with '×'" (`docs/SCREENS.md`
/// C1). One chip per non-default [DiscoverFilter] dimension — tapping a
/// chip clears just that dimension and reports the resulting filter via
/// [onFilterChanged]; `sortBy` never gets a chip (there's always some
/// sort active, so there's nothing to "clear").
///
/// Renders nothing when [filter] is already [DiscoverFilter.isDefault].
class FilteredListChipsRow extends StatelessWidget {
  const FilteredListChipsRow({
    super.key,
    required this.filter,
    required this.onFilterChanged,
  });

  final DiscoverFilter filter;
  final ValueChanged<DiscoverFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final chips = _activeChips(filter);
    if (chips.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final chip in chips)
          AppChip(
            label: chip.label,
            state: ChipState.selected,
            icon: AppIcons.close,
            onTap: () => onFilterChanged(chip.remove()),
          ),
      ],
    );
  }

  List<_ActiveChip> _activeChips(DiscoverFilter filter) {
    final chips = <_ActiveChip>[];

    if (filter.type != null) {
      chips.add(
        _ActiveChip(
          label: filter.type == MediaType.movie ? 'Movies' : 'TV Shows',
          remove: () => filter.copyWith(type: () => null),
        ),
      );
    }

    for (final genre in filter.withGenres) {
      chips.add(
        _ActiveChip(
          label: genre.name,
          remove: () => filter.copyWith(
            withGenres: Set.of(filter.withGenres)..remove(genre),
          ),
        ),
      );
    }

    for (final genre in filter.withoutGenres) {
      chips.add(
        _ActiveChip(
          label: 'No ${genre.name}',
          remove: () => filter.copyWith(
            withoutGenres: Set.of(filter.withoutGenres)..remove(genre),
          ),
        ),
      );
    }

    if (filter.yearFrom != null || filter.yearTo != null) {
      // 1950 is H8's own slider lower bound (`YearRangeFilter.minYear`);
      // redefined locally rather than imported across features, matching
      // how `YearRangeFilter` itself redefines `TasteYearSlider`'s copy.
      final from = filter.yearFrom ?? 1950;
      final to = filter.yearTo ?? DateTime.now().year;
      chips.add(
        _ActiveChip(
          label: '$from–$to',
          remove: () =>
              filter.copyWith(yearFrom: () => null, yearTo: () => null),
        ),
      );
    }

    if (filter.minVoteAverage != null && filter.minVoteAverage! > 0) {
      chips.add(
        _ActiveChip(
          label: '${filter.minVoteAverage!.toStringAsFixed(1)}+ rating',
          remove: () => filter.copyWith(minVoteAverage: () => null),
        ),
      );
    }

    if (filter.maxRuntimeMinutes != null) {
      chips.add(
        _ActiveChip(
          label: 'Under ${filter.maxRuntimeMinutes} min',
          remove: () => filter.copyWith(maxRuntimeMinutes: () => null),
        ),
      );
    }

    if (filter.tvStatus != null) {
      chips.add(
        _ActiveChip(
          label: filter.tvStatus == DiscoverTvStatus.airing
              ? 'Airing'
              : 'Ended',
          remove: () => filter.copyWith(tvStatus: () => null),
        ),
      );
    }

    return chips;
  }
}

class _ActiveChip {
  const _ActiveChip({required this.label, required this.remove});

  final String label;
  final DiscoverFilter Function() remove;
}
