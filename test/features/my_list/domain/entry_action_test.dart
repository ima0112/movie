import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/user_media_entry.dart';
import 'package:movies/core/domain/repositories/user_library_repository.dart';
import 'package:movies/features/my_list/domain/entry_action.dart';

const _key = MediaKey(type: MediaType.movie, tmdbId: 1);
const _base = UserMediaEntry(key: _key, title: 'Dune');

void main() {
  group('entryActionsFor', () {
    test('Watch later: watch it, favorite toggle, red removal last', () {
      expect(
        entryActionsFor(
          LibraryTab.watchLater,
          _base.copyWith(isWatchLater: true),
        ),
        [
          EntryAction.markWatched,
          EntryAction.addFavorite,
          EntryAction.removeWatchLater,
        ],
      );
    });

    test('Favorites: the other list is a toggle that follows the entry', () {
      final favorite = _base.copyWith(isFavorite: true);
      expect(entryActionsFor(LibraryTab.favorites, favorite), [
        EntryAction.markWatched,
        EntryAction.addWatchLater,
        EntryAction.removeFavorite,
      ]);
      expect(
        entryActionsFor(
          LibraryTab.favorites,
          favorite.copyWith(isWatchLater: true),
        )[1],
        EntryAction.removeWatchLater,
      );
    });

    test('Watched: edit instead of mark, favorite toggle, remove from '
        'Watched', () {
      final watched = _base.markWatched(rating: 4);
      expect(entryActionsFor(LibraryTab.watched, watched), [
        EntryAction.editWatched,
        EntryAction.addFavorite,
        EntryAction.removeFromWatched,
      ]);
      expect(
        entryActionsFor(
          LibraryTab.watched,
          watched.copyWith(isFavorite: true),
        )[1],
        EntryAction.removeFavorite,
      );
    });

    test('an already-watched favorite offers to edit, not to mark', () {
      final entry = _base.copyWith(isFavorite: true).markWatched();
      expect(
        entryActionsFor(LibraryTab.favorites, entry).first,
        EntryAction.editWatched,
      );
    });

    test('only the last action of every tab is a removal', () {
      for (final tab in LibraryTab.values) {
        final actions = entryActionsFor(tab, _base);
        expect(actions.last.isRemoval, isTrue);
        expect(actions.take(actions.length - 1).any((a) => a.isRemoval), false);
      }
    });
  });

  group('applyTo', () {
    test('toggles the flag, leaving the rest alone', () {
      final entry = _base.copyWith(isFavorite: true);
      final both = applyTo(entry, EntryAction.addWatchLater);
      expect(both.isFavorite, isTrue);
      expect(both.isWatchLater, isTrue);
      expect(applyTo(both, EntryAction.removeFavorite).isFavorite, isFalse);
    });

    test('the actions that open H2 or remove return the entry as is', () {
      expect(applyTo(_base, EntryAction.markWatched), _base);
      expect(applyTo(_base, EntryAction.removeFromWatched), _base);
    });
  });

  group('withoutIn', () {
    test('an entry in one list is left in none: null (delete it)', () {
      expect(
        withoutIn(LibraryTab.favorites, _base.copyWith(isFavorite: true)),
        isNull,
      );
      expect(
        withoutIn(LibraryTab.watched, _base.markWatched(rating: 3)),
        isNull,
      );
    });

    test('an entry in another list too keeps that one only', () {
      final entry = _base.copyWith(isFavorite: true).markWatched(rating: 5);

      final noFavorite = withoutIn(LibraryTab.favorites, entry)!;
      expect(noFavorite.isFavorite, isFalse);
      expect(noFavorite.isWatched, isTrue);
      expect(noFavorite.rating, 5);

      final unwatched = withoutIn(LibraryTab.watched, entry)!;
      expect(unwatched.isWatched, isFalse);
      expect(unwatched.rating, isNull);
      expect(unwatched.isFavorite, isTrue);
    });
  });
}
