import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/domain/entities/user_media_entry.dart';
import '../../../../core/domain/repositories/media_repository.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/l10n_extension.dart';
import '../cubit/my_list_cubit.dart';
import 'my_list_empty_state.dart';
import 'my_list_entry_tile.dart';

/// My List's row list (`docs/SCREENS.md` B4) — combines [MyListCubit]'s
/// selected tab/filter with `UserLibraryRepository.watch(tab:, type:)`'s
/// own stream directly. This is where the two sources actually meet
/// (CLAUDE.md rule 10: the Cubit never caches the list itself), which is
/// why this one widget needs the *whole* [MyListFilterState] — every
/// field of it (tab, type, sort, minStars, hideWatched) affects what's
/// rendered, so a single `BlocBuilder` here is justified, not the
/// screen-wide kind rule 9 forbids.
///
/// TODO: sorting only covers what `UserMediaEntry` can sort by today —
/// Watched by `watchedAt`/`rating`. Title/Year/TMDB rating need every
/// row's `MediaDetail` loaded up front, not fetched lazily per row the
/// way [MyListEntryTile] does it. Favorites/Watch later's "Recent" isn't
/// meaningful yet either: `UserMediaEntry` has no "date saved" field
/// (only `watchedAt`, Watched-only) — those rows keep the stream's own
/// order until one's added.
class MyListBody extends StatelessWidget {
  const MyListBody({
    super.key,
    required this.mediaRepository,
    required this.userLibraryRepository,
  });

  final MediaRepository mediaRepository;
  final UserLibraryRepository userLibraryRepository;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyListCubit, MyListFilterState>(
      builder: (context, state) {
        final tab = state.tab;
        final filter = state.currentFilter;
        return StreamBuilder<List<UserMediaEntry>>(
          stream: userLibraryRepository.watch(tab: tab, type: filter.type),
          builder: (context, snapshot) {
            final all = snapshot.data;
            if (all == null) return const SizedBox.shrink();

            final filtered = _applyFilter(all, tab, filter);
            if (filtered.isEmpty) {
              return all.isEmpty
                  ? MyListEmptyState(
                      tab: tab,
                      otherTabsNote: 'Explore to add movies and shows here.',
                      onExploreTap: () => context.go('/explore'),
                    )
                  : MyListFilteredEmptyState(
                      title: _filteredEmptyTitle(filter, context.l10n),
                      onSeeAllTap: () =>
                          context.read<MyListCubit>().resetCurrentTab(),
                    );
            }

            final sorted = _sort(filtered, tab, filter.sort);
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              itemCount: sorted.length,
              itemBuilder: (context, index) => MyListEntryTile(
                key: ValueKey(sorted[index].key),
                entry: sorted[index],
                tab: tab,
                mediaRepository: mediaRepository,
                userLibraryRepository: userLibraryRepository,
              ),
            );
          },
        );
      },
    );
  }

  static String _filteredEmptyTitle(TabFilter filter, AppLocalizations l10n) =>
      switch (filter.type) {
        null => 'Nothing matches your filters',
        MediaType.movie => l10n.myListFilteredEmptyMovieTitle,
        MediaType.tvShow => l10n.myListFilteredEmptyTvShowTitle,
      };

  static List<UserMediaEntry> _applyFilter(
    List<UserMediaEntry> entries,
    LibraryTab tab,
    TabFilter filter,
  ) {
    return entries.where((entry) {
      if (tab != LibraryTab.watched && filter.hideWatched && entry.isWatched) {
        return false;
      }
      if (tab == LibraryTab.watched &&
          filter.minStars != null &&
          (entry.rating ?? 0) < filter.minStars!) {
        return false;
      }
      return true;
    }).toList();
  }

  static List<UserMediaEntry> _sort(
    List<UserMediaEntry> entries,
    LibraryTab tab,
    MyListSort sort,
  ) {
    final sorted = [...entries];
    switch (sort) {
      case MyListSort.recent:
      case MyListSort.dateWatched:
        if (tab == LibraryTab.watched) {
          sorted.sort(
            (a, b) => (b.watchedAt ?? DateTime(0)).compareTo(
              a.watchedAt ?? DateTime(0),
            ),
          );
        }
      case MyListSort.myRating:
        sorted.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
      case MyListSort.titleAZ:
      case MyListSort.year:
      case MyListSort.tmdbRating:
        break; // TODO: needs eagerly-loaded MediaDetail per entry.
    }
    return sorted;
  }
}
