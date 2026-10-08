import 'package:flutter/material.dart';

import '../../core/domain/entities/discover_filter.dart';
import '../../core/domain/entities/genre_catalog.dart';
import '../../core/domain/entities/media_item.dart';
import '../../core/domain/entities/media_type.dart';
import '../../core/domain/entities/result.dart';
import '../../core/domain/repositories/media_repository.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/l10n_extension.dart';
import 'discover_range_filters.dart';
import 'discover_sort_chips.dart';
import 'explore_filter_actions.dart';
import 'filter_controls.dart';
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
///
/// Promoted from `features/explore/presentation/widgets/` to
/// `shared/widgets/` (along with its own supporting files:
/// `discover_range_filters.dart`, `discover_sort_chips.dart`,
/// `explore_filter_actions.dart`, `genre_multi_select_chips.dart`,
/// `tv_status_toggle.dart`) once `filtered_list` (C1) became this
/// widget's second real consumer — H8's own doc line above already
/// called out both, this just makes the file location match it.
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
    final l10n = context.l10n;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.filterSheetTitle, style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.xl),
            FilterSectionLabel(l10n.filterSheetSectionType),
            TypeFilterChips(
              type: _draft.type,
              onChanged: (type) => _setDraft(_draft.copyWith(type: () => type)),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilterSectionLabel(l10n.commonGenres),
            GenreMultiSelectChips(
              genres: GenreCatalog.all,
              selected: _draft.withGenres,
              onToggle: (genre) => _setDraft(
                _draft.copyWith(withGenres: _toggled(_draft.withGenres, genre)),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilterSectionLabel(l10n.filterSheetSectionYear),
            YearRangeFilter(
              yearFrom: _draft.yearFrom,
              yearTo: _draft.yearTo,
              onChanged: (from, to) => _setDraft(
                _draft.copyWith(yearFrom: () => from, yearTo: () => to),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilterSectionLabel(l10n.filterSheetSectionMinRating),
            MinRatingFilter(
              minVoteAverage: _draft.minVoteAverage,
              onChanged: (value) =>
                  _setDraft(_draft.copyWith(minVoteAverage: () => value)),
            ),
            if (isMovieOnly) ...[
              const SizedBox(height: AppSpacing.lg),
              FilterSectionLabel(l10n.filterSheetSectionMaxRuntime),
              MaxRuntimeFilter(
                maxRuntimeMinutes: _draft.maxRuntimeMinutes,
                onChanged: (value) =>
                    _setDraft(_draft.copyWith(maxRuntimeMinutes: () => value)),
              ),
            ],
            if (isTvOnly) ...[
              const SizedBox(height: AppSpacing.lg),
              FilterSectionLabel(l10n.filterSheetSectionStatus),
              TvStatusToggle(
                status: _draft.tvStatus,
                onChanged: (status) =>
                    _setDraft(_draft.copyWith(tvStatus: () => status)),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            FilterSectionLabel(l10n.filterSheetSectionSortBy),
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
