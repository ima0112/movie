import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';

/// My List's (B4) sort options — see `docs/SCREENS.md` H9 ("Sort and
/// filter My List"): "sort by Title A–Z / Year / TMDB rating and, in
/// Watched, My rating / Date watched". [myRating] and [dateWatched]
/// only make sense (and per H9 are only ever offered) in the Watched
/// tab — the widget that renders H9's chips decides which options to
/// show for the current tab, not this enum.
///
/// No `recent` option: it never had anywhere to read "date saved" from
/// for Favorites/Watch later (`UserMediaEntry` has no such field, only
/// `watchedAt`, Watched-only), so it was always a silent no-op there —
/// removed rather than kept as a chip that does nothing. [dateWatched]
/// already covers the one tab (Watched) where "most recent" has a real
/// column to sort by.
enum MyListSort { titleAZ, year, tmdbRating, myRating, dateWatched }

/// One [LibraryTab]'s own H9 filter/sort selection.
///
/// Split out from [MyListFilterState] because H9 "remembers state per
/// tab" — switching from Watched (say, sorted by My rating with a 3★
/// minimum) to Favorites and back must still show that same Watched
/// selection, not a shared one reset by whatever Favorites last had.
class TabFilter {
  const TabFilter({
    this.type,
    this.sort = MyListSort.titleAZ,
    this.minStars,
    this.hideWatched = false,
  });

  /// `null` = "All" (`docs/SCREENS.md` H9: "Type (All/Movies/TV
  /// Shows)").
  final MediaType? type;
  final MyListSort sort;

  /// 1–5, Watched tab only (H9: "minimum rating (★1–5)"). `null` = no
  /// minimum set.
  final int? minStars;

  /// Favorites/Watch later only (H9: "'Hide what I've watched'").
  final bool hideWatched;

  /// H9's "Reset" only shows "if something's active" — i.e. this isn't
  /// the default.
  bool get isDefault => this == const TabFilter();

  @override
  bool operator ==(Object other) =>
      other is TabFilter &&
      other.type == type &&
      other.sort == sort &&
      other.minStars == minStars &&
      other.hideWatched == hideWatched;

  @override
  int get hashCode => Object.hash(type, sort, minStars, hideWatched);

  @override
  String toString() =>
      'TabFilter(type: $type, sort: $sort, minStars: $minStars, '
      'hideWatched: $hideWatched)';
}

/// Which [LibraryTab] My List is currently showing, and each tab's own
/// [TabFilter] (H9 "remembers state per tab").
///
/// [showsPeople] is the People tab (saved people, not a [LibraryTab]: they
/// have no type, sort or rating to filter by). While it is on, [tab] keeps
/// the last library tab, so coming back to it finds its own filter.
class MyListFilterState {
  MyListFilterState({
    this.tab = LibraryTab.favorites,
    this.showsPeople = false,
    Map<LibraryTab, TabFilter>? filters,
  }) : filters =
           filters ??
           {for (final tab in LibraryTab.values) tab: const TabFilter()};

  final LibraryTab tab;
  final bool showsPeople;
  final Map<LibraryTab, TabFilter> filters;

  /// The selected [tab]'s own filter — what H9 and the row list both
  /// read.
  TabFilter get currentFilter => filters[tab]!;

  @override
  bool operator ==(Object other) =>
      other is MyListFilterState &&
      other.tab == tab &&
      other.showsPeople == showsPeople &&
      mapEquals(other.filters, filters);

  // `filters.entries` can't feed `Object.hashAll` directly — `MapEntry`
  // has no `==`/`hashCode` of its own, which would silently break the
  // `==`/`hashCode` contract (two equal states could hash differently).
  // `LibraryTab` only ever has 3 fixed values, so hashing each one's
  // `TabFilter` directly is both correct and simpler.
  @override
  int get hashCode => Object.hash(
    tab,
    showsPeople,
    filters[LibraryTab.favorites],
    filters[LibraryTab.watchLater],
    filters[LibraryTab.watched],
  );

  @override
  String toString() => 'MyListFilterState(tab: $tab, filters: $filters)';
}

/// Owns which [LibraryTab] is selected and each tab's own H9
/// filter/sort — nothing else.
///
/// Deliberately does **not** hold `UserMediaEntry` data or touch
/// [UserLibraryRepository] at all (CLAUDE.md rule 10: "Don't create a
/// library-wide Cubit holding an in-memory copy of the whole list").
/// The screen combines this Cubit's [MyListFilterState] with
/// `UserLibraryRepository.watch(tab:, type:)`'s stream itself — sorting
/// and the minimum-stars/hide-watched filters are applied to whatever
/// that stream emits, not cached here. That keeps this Cubit's job to
/// exactly one thing: which tab/filter is selected, the same discipline
/// rule 9 applies to widget rebuilds, applied here to data ownership
/// instead.
class MyListCubit extends Cubit<MyListFilterState> {
  MyListCubit() : super(MyListFilterState());

  void selectTab(LibraryTab tab) {
    emit(MyListFilterState(tab: tab, filters: state.filters));
  }

  /// The People tab: the library tab and its filters stay as they were.
  void selectPeople() {
    emit(
      MyListFilterState(
        tab: state.tab,
        showsPeople: true,
        filters: state.filters,
      ),
    );
  }

  /// `null` selects "All".
  void selectType(MediaType? type) {
    _updateCurrentTab(
      (f) => TabFilter(
        type: type,
        sort: f.sort,
        minStars: f.minStars,
        hideWatched: f.hideWatched,
      ),
    );
  }

  void selectSort(MyListSort sort) {
    _updateCurrentTab(
      (f) => TabFilter(
        type: f.type,
        sort: sort,
        minStars: f.minStars,
        hideWatched: f.hideWatched,
      ),
    );
  }

  /// `null` clears the minimum-stars filter.
  void selectMinStars(int? minStars) {
    _updateCurrentTab(
      (f) => TabFilter(
        type: f.type,
        sort: f.sort,
        minStars: minStars,
        hideWatched: f.hideWatched,
      ),
    );
  }

  void setHideWatched(bool hideWatched) {
    _updateCurrentTab(
      (f) => TabFilter(
        type: f.type,
        sort: f.sort,
        minStars: f.minStars,
        hideWatched: hideWatched,
      ),
    );
  }

  /// H9's "Reset" — clears only the currently selected tab's filter.
  void resetCurrentTab() {
    _updateCurrentTab((_) => const TabFilter());
  }

  void _updateCurrentTab(TabFilter Function(TabFilter current) update) {
    final updated = update(state.filters[state.tab]!);
    emit(
      MyListFilterState(
        tab: state.tab,
        showsPeople: state.showsPeople,
        filters: {...state.filters, state.tab: updated},
      ),
    );
  }
}
