import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/domain/entities/discover_filter.dart';
import '../../core/domain/entities/genre_catalog.dart';
import '../../core/domain/entities/result.dart';
import '../../core/domain/repositories/media_repository.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/l10n_extension.dart';
import 'app_buttons.dart';
import 'discover_range_filters.dart';
import 'discover_sort_chips.dart';
import 'filter_platform_chips.dart';
import 'filter_section_header.dart';
import 'genre_multi_select_chips.dart';

/// H8 (Filters) — `docs/SCREENS.md` H8. Used from both B2 and C1, so it takes
/// an [initialFilter] and calls [onApply] rather than reading one screen's
/// Cubit.
///
/// **Five filters, in this order:** sort, streaming platform, genres, years,
/// minimum rating. The kind of title (All / Movies / TV Shows) isn't one of
/// them: it is the segment of the screen that opened the sheet, so
/// [initialFilter] carries it and the sheet never changes it.
///
/// Edits a local draft — nothing reaches [onApply] until "See N results", and
/// swiping closed discards it. "Clear" (top right, only while something is
/// set) puts the draft back to the default: every title of the segment, most
/// popular first — never an empty state.
///
/// The button's N is live: the draft's total is requested (debounced, so a
/// dragged slider doesn't fire a request per tick) and a slow answer to an
/// old draft can't overwrite a newer one's. With no match the button is
/// disabled and says so.
class ExploreFilterSheet extends StatefulWidget {
  const ExploreFilterSheet({
    super.key,
    required this.initialFilter,
    required this.mediaRepository,
    required this.regionName,
    required this.onApply,
  });

  final DiscoverFilter initialFilter;
  final MediaRepository mediaRepository;

  /// The Settings region's display name, shown next to the streaming row.
  final String regionName;
  final ValueChanged<DiscoverFilter> onApply;

  @override
  State<ExploreFilterSheet> createState() => _ExploreFilterSheetState();
}

class _ExploreFilterSheetState extends State<ExploreFilterSheet> {
  static const Duration _countDebounce = Duration(milliseconds: 350);

  late DiscoverFilter _draft;
  int? _liveCount;
  int _queryGeneration = 0;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _draft = widget.initialFilter;
    unawaited(_refreshCount());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _setDraft(DiscoverFilter next) {
    setState(() {
      _draft = next;
      _liveCount = null;
    });
    _debounce?.cancel();
    _debounce = Timer(_countDebounce, _refreshCount);
  }

  Future<void> _refreshCount() async {
    final generation = ++_queryGeneration;
    final result = await widget.mediaRepository.discoverPage(_draft);
    if (!mounted || generation != _queryGeneration) return;

    setState(() {
      _liveCount = switch (result) {
        Success(:final value) => value.totalResults,
        Failure() => null,
      };
    });
  }

  void _apply() {
    widget.onApply(_draft);
    Navigator.of(context).pop();
  }

  /// What "Clear" goes back to: the default filter of the same segment.
  DiscoverFilter get _cleared =>
      DiscoverFilter(type: widget.initialFilter.type);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final count = _liveCount;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenMargin,
          0,
          AppSpacing.screenMargin,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.filterSheetTitle, style: AppTextStyles.h1),
                if (_draft != _cleared)
                  TextLinkButton(
                    label: l10n.filterSheetClear,
                    fullWidth: false,
                    onTap: () => _setDraft(_cleared),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            FilterSectionHeader(l10n.filterSheetSectionSortBy),
            DiscoverSortChips(
              sortBy: _draft.sortBy,
              onChanged: (sortBy) => _setDraft(_draft.copyWith(sortBy: sortBy)),
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            FilterPlatformChips(
              mediaRepository: widget.mediaRepository,
              type: _draft.type,
              regionName: widget.regionName,
              selectedId: _draft.withWatchProviders.firstOrNull,
              onChanged: (id) => _setDraft(
                _draft.copyWith(withWatchProviders: id == null ? {} : {id}),
              ),
            ),
            FilterSectionHeader(l10n.commonGenres),
            GenreMultiSelectChips(
              genres: GenreCatalog.all,
              selected: _draft.withGenres,
              onToggle: (genre) => _setDraft(
                _draft.copyWith(withGenres: _toggled(_draft.withGenres, genre)),
              ),
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            YearRangeFilter(
              yearFrom: _draft.yearFrom,
              yearTo: _draft.yearTo,
              onChanged: (from, to) => _setDraft(
                _draft.copyWith(yearFrom: () => from, yearTo: () => to),
              ),
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            MinRatingFilter(
              minVoteAverage: _draft.minVoteAverage,
              onChanged: (value) =>
                  _setDraft(_draft.copyWith(minVoteAverage: () => value)),
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            PrimaryButton(
              label: switch (count) {
                null => l10n.filterSheetSeeResultsLoading,
                0 => l10n.filterSheetNoResults,
                _ => l10n.filterSheetSeeResultsCount(count),
              },
              isDisabled: count == 0,
              onTap: _apply,
            ),
          ],
        ),
      ),
    );
  }

  static Set<T> _toggled<T>(Set<T> set, T value) {
    final next = Set<T>.of(set);
    if (!next.remove(value)) next.add(value);
    return next;
  }
}
