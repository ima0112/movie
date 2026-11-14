import 'package:flutter/material.dart';

import '../../../../core/domain/entities/discover_filter.dart';
import '../../../../core/domain/entities/discover_preset.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/discover_preset_localization.dart';
import '../../../../l10n/genre_localization.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_chip.dart';
import '../../../../shared/widgets/original_language_catalog.dart';
import '../../../../shared/widgets/year_range_fields.dart';

/// C1's row of active filters, one amber chip each with a "×" — a single line
/// that scrolls sideways when it doesn't fit. Tapping a chip clears just that
/// filter and reports the resulting filter via [onFilterChanged]. The sort and
/// the kind of title (the segment) never get a chip. [providerNames] names the
/// streaming-service chip (a service whose name isn't known yet has none).
///
/// Renders nothing when no filter is set.
class FilteredListChipsRow extends StatelessWidget {
  const FilteredListChipsRow({
    super.key,
    required this.filter,
    required this.providerNames,
    required this.onFilterChanged,
  });

  final DiscoverFilter filter;
  final Map<int, String> providerNames;
  final ValueChanged<DiscoverFilter> onFilterChanged;

  static const double height = 40;

  @override
  Widget build(BuildContext context) {
    final chips = _activeChips(filter, context.l10n);
    if (chips.isEmpty) return const SizedBox.shrink();

    // A margin under the chips: they are the last line of the header, and the
    // grid's top fade starts below it.
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: SizedBox(
        height: height,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenMargin,
          ),
          itemCount: chips.length,
          separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (context, index) {
            final chip = chips[index];
            return Center(
              child: AppChip(
                label: chip.label,
                state: ChipState.selected,
                trailingIcon: AppIcons.close,
                onTap: () => onFilterChanged(chip.remove()),
              ),
            );
          },
        ),
      ),
    );
  }

  List<_ActiveChip> _activeChips(DiscoverFilter filter, AppLocalizations l10n) {
    final chips = <_ActiveChip>[];

    if (filter.preset case final preset?) {
      chips.add(
        _ActiveChip(
          label: preset.localizedLabel(l10n),
          remove: () => filter.withPreset(null),
        ),
      );
    }

    for (final id in filter.withWatchProviders) {
      final name = providerNames[id];
      if (name == null) continue;
      chips.add(
        _ActiveChip(
          label: name,
          remove: () => filter.copyWith(
            withWatchProviders: Set.of(filter.withWatchProviders)..remove(id),
          ),
        ),
      );
    }

    for (final genre in filter.withGenres) {
      chips.add(
        _ActiveChip(
          label: genre.localizedName(l10n),
          remove: () => filter.copyWith(
            withGenres: Set.of(filter.withGenres)..remove(genre),
          ),
        ),
      );
    }

    for (final genre in filter.withoutGenres) {
      chips.add(
        _ActiveChip(
          label: l10n.filteredListExcludeGenreChip(genre.localizedName(l10n)),
          remove: () => filter.copyWith(
            withoutGenres: Set.of(filter.withoutGenres)..remove(genre),
          ),
        ),
      );
    }

    if (filter.yearFrom != null || filter.yearTo != null) {
      final from = filter.yearFrom ?? YearRangeFields.minYear;
      final to = filter.yearTo ?? YearRangeFields.maxYear;
      chips.add(
        _ActiveChip(
          label: l10n.filteredListYearRangeChip(from, to),
          remove: () =>
              filter.copyWith(yearFrom: () => null, yearTo: () => null),
        ),
      );
    }

    if (filter.hasRatingRange) {
      final low = filter.minVoteAverage ?? 0;
      final high = filter.maxVoteAverage;
      chips.add(
        _ActiveChip(
          label: high == null
              ? l10n.filteredListMinRatingChip(low.toStringAsFixed(1))
              : l10n.filteredListRatingRangeChip(
                  low.toStringAsFixed(1),
                  high.toStringAsFixed(1),
                ),
          remove: () => filter.copyWith(
            minVoteAverage: () => null,
            maxVoteAverage: () => null,
          ),
        ),
      );
    }

    if (filter.originalLanguage case final code?) {
      chips.add(
        _ActiveChip(
          label: originalLanguageName(code),
          remove: () => filter.copyWith(originalLanguage: () => null),
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
