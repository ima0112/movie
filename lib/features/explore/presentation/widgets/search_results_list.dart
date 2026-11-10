import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_tab_bar.dart';

import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/media_segment.dart';
import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/media_type_localization.dart';

/// B2's State 2 results list — "Row = thumbnail (circular for people),
/// title, 'Year · Movie/TV Show' or 'Department · Person'... The
/// segment filters client-side (All shows all three types; Movies/TV
/// Shows hide people)... Infinite scroll" (`docs/SCREENS.md` B2).
///
/// Takes the *unfiltered* [results] plus [segment] and filters by type
/// internally — `ExploreSearchLoaded.results`' own doc comment already
/// calls this out as a presentation-layer concern over that one list,
/// not a second network call or Cubit state.
///
/// **Two gaps, not fixed here**: `MediaRepository.searchMulti` only
/// ever returns `MediaItem` (movies/TV shows) — no `Person` results
/// exist yet to sort last or show with a circular thumbnail/"Department
/// · Person" line, so this only ever renders the movie/TV row shape.
/// And `ExploreCubit`/`ExploreSearchLoaded` fetch the *whole* result set
/// in one call — there's no `loadMore()` here the way `FilteredListCubit`
/// has one for C1 — so "infinite scroll" today is only `ListView.builder`'s
/// own lazy widget building, not real paginated fetching; wiring actual
/// paging through here is a job for whenever `searchMulti` itself grows
/// a page parameter.
class SearchResultsList extends StatelessWidget {
  const SearchResultsList({
    super.key,
    required this.results,
    required this.segment,
    required this.onTap,
  });

  final List<MediaItem> results;
  final MediaSegment segment;
  final ValueChanged<MediaItem> onTap;

  static const double _posterWidth = 56;
  static const double _posterHeight = 84;

  @override
  Widget build(BuildContext context) {
    final visible = switch (segment) {
      MediaSegment.all => results,
      MediaSegment.movie => results.where((i) => i.type == MediaType.movie),
      MediaSegment.tvShow => results.where((i) => i.type == MediaType.tvShow),
    }.toList();

    return ListView.builder(
      padding: EdgeInsets.only(bottom: AppTabBar.scrollInset(context)),
      itemCount: visible.length,
      itemBuilder: (context, index) {
        final item = visible[index];
        return _ResultRow(item: item, onTap: () => onTap(item));
      },
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.item, required this.onTap});

  final MediaItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: SizedBox(
                width: SearchResultsList._posterWidth,
                height: SearchResultsList._posterHeight,
                child: item.posterUrl == null
                    ? const ColoredBox(color: AppColors.surfaceRaised)
                    : Image.network(item.posterUrl!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title,
                    style: AppTextStyles.h3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _metadata(item, context.l10n),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _metadata(MediaItem item, AppLocalizations l10n) {
    final year = item.releaseDate?.year;
    final typeLabel = item.type.localizedSingular(l10n);
    return year == null
        ? typeLabel
        : l10n.exploreResultMetadata(year, typeLabel);
  }
}
