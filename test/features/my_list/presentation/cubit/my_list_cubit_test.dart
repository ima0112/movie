import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/repositories/user_library_repository.dart';
import 'package:movies/features/my_list/presentation/cubit/my_list_cubit.dart';

// No repository/fake needed anywhere in this file — MyListCubit never
// touches UserLibraryRepository (CLAUDE.md rule 10); it only tracks
// which tab is selected and each tab's own filter.
void main() {
  group('MyListCubit', () {
    test('starts on Favorites with every tab at its default TabFilter', () {
      final cubit = MyListCubit();

      expect(cubit.state.tab, LibraryTab.favorites);
      for (final tab in LibraryTab.values) {
        expect(cubit.state.filters[tab], const TabFilter());
      }
      cubit.close();
    });

    test('selectTab switches the selected tab without touching any '
        "tab's filter", () {
      final cubit = MyListCubit();
      cubit.selectSort(MyListSort.year); // sets Favorites' filter

      cubit.selectTab(LibraryTab.watched);

      expect(cubit.state.tab, LibraryTab.watched);
      expect(cubit.state.filters[LibraryTab.favorites]!.sort, MyListSort.year);
      expect(cubit.state.filters[LibraryTab.watched], const TabFilter());
      cubit.close();
    });

    test('selectPeople shows the People tab and keeps the library tab and its '
        'filter; selectTab leaves it', () {
      final cubit = MyListCubit();
      cubit.selectTab(LibraryTab.watched);
      cubit.selectMinStars(4);

      cubit.selectPeople();
      expect(cubit.state.showsPeople, isTrue);
      expect(cubit.state.tab, LibraryTab.watched);
      expect(cubit.state.currentFilter.minStars, 4);

      cubit.selectTab(LibraryTab.watched);
      expect(cubit.state.showsPeople, isFalse);
      expect(cubit.state.currentFilter.minStars, 4);
      cubit.close();
    });

    test('each tab remembers its own filter independently (H9: "remembers '
        'state per tab")', () {
      final cubit = MyListCubit();

      cubit.selectTab(LibraryTab.watched);
      cubit.selectSort(MyListSort.myRating);
      cubit.selectMinStars(3);

      cubit.selectTab(LibraryTab.favorites);
      cubit.selectSort(MyListSort.titleAZ);

      cubit.selectTab(LibraryTab.watched);
      expect(cubit.state.currentFilter.sort, MyListSort.myRating);
      expect(cubit.state.currentFilter.minStars, 3);
      expect(
        cubit.state.filters[LibraryTab.favorites]!.sort,
        MyListSort.titleAZ,
      );
      cubit.close();
    });

    test('selectType sets the current tab\'s type, and null selects "All"', () {
      final cubit = MyListCubit();

      cubit.selectType(MediaType.movie);
      expect(cubit.state.currentFilter.type, MediaType.movie);

      cubit.selectType(null);
      expect(cubit.state.currentFilter.type, isNull);
      cubit.close();
    });

    test(
      'selectMinStars sets the current tab\'s minimum, and null clears it',
      () {
        final cubit = MyListCubit();

        cubit.selectMinStars(4);
        expect(cubit.state.currentFilter.minStars, 4);

        cubit.selectMinStars(null);
        expect(cubit.state.currentFilter.minStars, isNull);
        cubit.close();
      },
    );

    test('setHideWatched sets the current tab\'s hideWatched flag', () {
      final cubit = MyListCubit();
      cubit.setHideWatched(true);
      expect(cubit.state.currentFilter.hideWatched, isTrue);
      cubit.close();
    });

    test('resetCurrentTab clears only the selected tab back to defaults', () {
      final cubit = MyListCubit();
      cubit.selectType(MediaType.tvShow);
      cubit.selectSort(MyListSort.year);
      cubit.selectTab(LibraryTab.watched);
      cubit.selectMinStars(5);

      cubit.resetCurrentTab();

      expect(cubit.state.currentFilter, const TabFilter());
      expect(
        cubit.state.filters[LibraryTab.favorites],
        const TabFilter(type: MediaType.tvShow, sort: MyListSort.year),
      );
      cubit.close();
    });

    test('the default TabFilter sorts by Title A-Z, not "Recent" (removed '
        '— it was a no-op for Favorites/Watch later, with no "date saved" '
        'field to sort by)', () {
      expect(const TabFilter().sort, MyListSort.titleAZ);
    });

    test('TabFilter.isDefault is true only for the untouched default', () {
      const defaultFilter = TabFilter();
      const changedFilter = TabFilter(minStars: 2);

      expect(defaultFilter.isDefault, isTrue);
      expect(changedFilter.isDefault, isFalse);
    });
  });
}
