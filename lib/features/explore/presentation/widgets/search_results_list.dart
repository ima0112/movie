import 'package:flutter/material.dart';

import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/media_segment.dart';
import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/domain/entities/person.dart';
import '../../../../core/domain/entities/search_result.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_tab_bar.dart';
import '../../../../shared/widgets/person_result_row.dart';
import 'search_result_rows.dart';

/// B2's State 2 results list — D3b's list tile for every row, on the page
/// margin with hairlines between them (`docs/SCREENS.md` B2). The segment
/// filters client-side: All shows everything, Movies and TV Shows hide people,
/// People shows only people.
///
/// Takes the *unfiltered*, already ordered [results] plus [segment] and
/// filters by type internally — `ExploreSearchLoaded.results`' own doc
/// comment calls this out as a presentation-layer concern over that one
/// list, not a second network call or Cubit state. A title opens D1/D2
/// ([onMediaTap]); a person opens D3 ([onPersonTap]).
///
/// One gap, not fixed here: `ExploreCubit`/`ExploreSearchLoaded` fetch the
/// *whole* result set in one call, so "infinite scroll" today is only
/// `ListView.builder`'s own lazy widget building, not real paginated fetching.
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

  /// The results [segment] lets through.
  static List<SearchResult> visibleIn(
    List<SearchResult> results,
    MediaSegment segment,
  ) => [
    for (final result in results)
      if (switch ((segment, result)) {
        (MediaSegment.all, _) => true,
        (MediaSegment.movie, MediaResult(:final item)) =>
          item.type == MediaType.movie,
        (MediaSegment.tvShow, MediaResult(:final item)) =>
          item.type == MediaType.tvShow,
        (MediaSegment.person, PersonResult()) => true,
        _ => false,
      })
        result,
  ];

  @override
  Widget build(BuildContext context) {
    final visible = visibleIn(results, segment);
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenMargin,
        0,
        AppSpacing.screenMargin,
        AppTabBar.scrollInset(context),
      ),
      itemCount: visible.length,
      itemBuilder: (context, index) => switch (visible[index]) {
        MediaResult(:final item) => MediaResultRow(
          item: item,
          onTap: () => onMediaTap(item),
        ),
        PersonResult(:final person) => PersonResultRow(
          person: person,
          onTap: () => onPersonTap(person),
        ),
      },
    );
  }
}
