import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_tab_bar.dart';

import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/media_segment.dart';
import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/domain/entities/person.dart';
import '../../../../core/domain/entities/search_result.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/media_type_localization.dart';
import '../../../../shared/widgets/profile_image.dart';

/// B2's State 2 results list — "Row = thumbnail (circular for people),
/// title, 'Year · Movie/TV Show' or 'Department · Person'... The
/// segment filters client-side (All shows all three types; Movies/TV
/// Shows hide people)... Infinite scroll" (`docs/SCREENS.md` B2).
///
/// Takes the *unfiltered*, already ordered [results] plus [segment] and
/// filters by type internally — `ExploreSearchLoaded.results`' own doc
/// comment calls this out as a presentation-layer concern over that one
/// list, not a second network call or Cubit state. A title opens D1/D2
/// ([onMediaTap]); a person opens D3 ([onPersonTap]).
///
/// One gap, not fixed here: `ExploreCubit`/`ExploreSearchLoaded` fetch the
/// *whole* result set in one call — there's no `loadMore()` the way
/// `FilteredListCubit` has one for C1 — so "infinite scroll" today is only
/// `ListView.builder`'s own lazy widget building, not real paginated
/// fetching; wiring actual paging through here is a job for whenever
/// `searchMulti` itself grows a page parameter.
class SearchResultsList extends StatelessWidget {
  const SearchResultsList({
    super.key,
    required this.results,
    required this.segment,
    required this.onMediaTap,
    required this.onPersonTap,
  });

  final List<SearchResult> results;
  final MediaSegment segment;
  final ValueChanged<MediaItem> onMediaTap;
  final ValueChanged<Person> onPersonTap;

  static const double _posterWidth = 56;
  static const double _posterHeight = 84;

  @override
  Widget build(BuildContext context) {
    final visible = [
      for (final result in results)
        if (switch ((segment, result)) {
          (MediaSegment.all, _) => true,
          (MediaSegment.movie, MediaResult(:final item)) =>
            item.type == MediaType.movie,
          (MediaSegment.tvShow, MediaResult(:final item)) =>
            item.type == MediaType.tvShow,
          // Movies / TV Shows hide people.
          _ => false,
        })
          result,
    ];

    return ListView.builder(
      padding: EdgeInsets.only(bottom: AppTabBar.scrollInset(context)),
      itemCount: visible.length,
      itemBuilder: (context, index) => switch (visible[index]) {
        MediaResult(:final item) => _MediaRow(
          item: item,
          onTap: () => onMediaTap(item),
        ),
        PersonResult(:final person) => _PersonRow(
          person: person,
          onTap: () => onPersonTap(person),
        ),
      },
    );
  }
}

class _MediaRow extends StatelessWidget {
  const _MediaRow({required this.item, required this.onTap});

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

/// A person's row: a circular photo (initial when there is none), the name,
/// and "Department · Person".
class _PersonRow extends StatelessWidget {
  const _PersonRow({required this.person, required this.onTap});

  final Person person;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final department = person.knownForDepartment;
    final metadata = department == null || department.isEmpty
        ? l10n.explorePersonLabel
        : l10n.explorePersonMetadata(department);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            // Same slot as a poster, so rows line up; the photo is round.
            SizedBox(
              width: SearchResultsList._posterWidth,
              height: SearchResultsList._posterHeight,
              child: Center(
                child: ClipOval(
                  child: SizedBox(
                    width: SearchResultsList._posterWidth,
                    height: SearchResultsList._posterWidth,
                    child: ProfileImage(
                      profilePath: person.profilePath,
                      name: person.name,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    person.name,
                    style: AppTextStyles.h3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    metadata,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.inkMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
