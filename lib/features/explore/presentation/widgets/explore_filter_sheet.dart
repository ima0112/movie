import 'package:flutter/material.dart';

import '../../../../core/domain/entities/discover_filter.dart';
import '../../../../core/domain/entities/genre_catalog.dart';
import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/domain/entities/result.dart';
import '../../../../core/domain/repositories/media_repository.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/filter_controls.dart';
import 'discover_range_filters.dart';
import 'discover_sort_chips.dart';
import 'explore_filter_actions.dart';
import 'genre_multi_select_chips.dart';
import 'tv_status_toggle.dart';

/// H8 (Filters) — `docs/SCREENS.md` H8. Used from both B2 and C1 (H8's
/// own "Access: B2, C1"), so this takes an [initialFilter] and calls
/// [onApply] rather than reading one specific screen's Cubit directly.
///
/// Edits a local draft — nothing reaches [onApply] until "Apply", and
/// swiping closed discards it, the same "draft, not live" discipline
/// `MyListFilterSheet` (H9) already established.
///
/// "See N results (N live)": [mediaRepository] is queried with the
/// current draft on every change, generation-guarded the same way
/// `ExploreCubit` guards its own debounced search so a slow response to
/// an old draft can't overwrite a newer one's count.
///
/// Not modeled at all: "Hide what I've watched" — see `DiscoverFilter`'s
/// own doc comment for why.
class ExploreFilterSheet extends StatefulWidget {
  const ExploreFilterSheet({
    super.key,
    required this.initialFilter,
    required this.mediaRepository,
    required this.onApply,
  });

  final DiscoverFilter initialFilter;
  final MediaRepository mediaRepository;
  final ValueChanged<DiscoverFilter> onApply;

  @override
  State<ExploreFilterSheet> createState() => _ExploreFilterSheetState();
}

class _ExploreFilterSheetState extends State<ExploreFilterSheet> {
  late DiscoverFilter _draft;
  int? _liveCount;
  int _queryGeneration = 0;

  @override
  void initState() {
    super.initState();
    _draft = widget.initialFilter;
    _refreshCount();
  }

  void _setDraft(DiscoverFilter next) {
    setState(() => _draft = next);
    _refreshCount();
  }

  Future<void> _refreshCount() async {
    final generation = ++_queryGeneration;
    final result = await widget.mediaRepository.discover(_draft);
    if (!mounted || generation != _queryGeneration) return;

    setState(() {
      _liveCount = switch (result) {
        Success<List<MediaItem>>(:final value) => value.length,
        Failure<List<MediaItem>>() => null,
      };
    });
  }

  void _apply() {
    widget.onApply(_draft);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isMovieOnly = _draft.type == MediaType.movie;
    final isTvOnly = _draft.type == MediaType.tvShow;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filters', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.xl),
            const FilterSectionLabel('Type'),
            TypeFilterChips(
              type: _draft.type,
              onChanged: (type) => _setDraft(_draft.copyWith(type: () => type)),
            ),
            const SizedBox(height: AppSpacing.lg),
            const FilterSectionLabel('Genres'),
            GenreMultiSelectChips(
              genres: GenreCatalog.all,
              selected: _draft.withGenres,
              onToggle: (genre) => _setDraft(
                _draft.copyWith(withGenres: _toggled(_draft.withGenres, genre)),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const FilterSectionLabel('Year'),
            YearRangeFilter(
              yearFrom: _draft.yearFrom,
              yearTo: _draft.yearTo,
              onChanged: (from, to) => _setDraft(
                _draft.copyWith(yearFrom: () => from, yearTo: () => to),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const FilterSectionLabel('Minimum rating'),
            MinRatingFilter(
              minVoteAverage: _draft.minVoteAverage,
              onChanged: (value) =>
                  _setDraft(_draft.copyWith(minVoteAverage: () => value)),
            ),
            if (isMovieOnly) ...[
              const SizedBox(height: AppSpacing.lg),
              const FilterSectionLabel('Max runtime'),
              MaxRuntimeFilter(
                maxRuntimeMinutes: _draft.maxRuntimeMinutes,
                onChanged: (value) =>
                    _setDraft(_draft.copyWith(maxRuntimeMinutes: () => value)),
              ),
            ],
            if (isTvOnly) ...[
              const SizedBox(height: AppSpacing.lg),
              const FilterSectionLabel('Status'),
              TvStatusToggle(
                status: _draft.tvStatus,
                onChanged: (status) =>
                    _setDraft(_draft.copyWith(tvStatus: () => status)),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            const FilterSectionLabel('Sort by'),
            DiscoverSortChips(
              sortBy: _draft.sortBy,
              onChanged: (sortBy) => _setDraft(_draft.copyWith(sortBy: sortBy)),
            ),
            const SizedBox(height: AppSpacing.xxl),
            ExploreFilterActions(
              showReset: !_draft.isDefault,
              onReset: () => _setDraft(const DiscoverFilter()),
              liveCount: _liveCount,
              onApply: _apply,
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
