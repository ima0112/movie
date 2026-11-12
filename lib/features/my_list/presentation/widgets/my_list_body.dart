import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/domain/entities/user_media_entry.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_tab_bar.dart';
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
class MyListBody extends StatelessWidget {
  const MyListBody({super.key, required this.userLibraryRepository});

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
                      otherTabsNote: context.l10n.myListBodyOtherTabsNote,
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
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenMargin,
                0,
                AppSpacing.screenMargin,
                AppTabBar.scrollInset(context),
              ),
              itemCount: sorted.length,
              itemBuilder: (context, index) => MyListEntryTile(
                key: ValueKey(sorted[index].key),
                entry: sorted[index],
                tab: tab,
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
        null => l10n.myListBodyEmptyFilterTitle,
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
        sorted.sort(_byTitle);
      case MyListSort.year:
        sorted.sort(_byYearThenTitle);
      case MyListSort.tmdbRating:
        sorted.sort(_byRatingThenTitle);
    }
    return sorted;
  }

  static int _byTitle(UserMediaEntry a, UserMediaEntry b) =>
      a.title.toLowerCase().compareTo(b.title.toLowerCase());

  // Most recent year first; an entry saved before `year` existed (null)
  // always sorts after one that has it, regardless of direction.
  static int _byYearThenTitle(UserMediaEntry a, UserMediaEntry b) {
    if (a.year == null && b.year == null) return _byTitle(a, b);
    if (a.year == null) return 1;
    if (b.year == null) return -1;
    final byYear = b.year!.compareTo(a.year!);
    return byYear != 0 ? byYear : _byTitle(a, b);
  }

  // Highest TMDB rating first; same null-goes-last rule as year above.
  static int _byRatingThenTitle(UserMediaEntry a, UserMediaEntry b) {
    if (a.voteAverage == null && b.voteAverage == null) return _byTitle(a, b);
    if (a.voteAverage == null) return 1;
    if (b.voteAverage == null) return -1;
    final byRating = b.voteAverage!.compareTo(a.voteAverage!);
    return byRating != 0 ? byRating : _byTitle(a, b);
  }
}
