import '../../../core/domain/entities/user_media_entry.dart';
import '../../../core/domain/repositories/user_library_repository.dart';

/// What the three-dot sheet of a My List row (`docs/SCREENS.md` H1) can do to
/// an entry. Pure: [entryActionsFor] decides which ones a row offers,
/// [applyTo] and [withoutIn] say what each one does to the entry.
enum EntryAction {
  /// Opens H2 for an entry that isn't watched yet.
  markWatched,

  /// Opens H2 on an already-watched entry (its rating and date).
  editWatched,
  addFavorite,
  removeFavorite,
  addWatchLater,
  removeWatchLater,

  /// "Remove from Watched" — the red one of the Watched tab.
  removeFromWatched;

  /// The removal ones are drawn in red, last.
  bool get isRemoval =>
      this == removeFavorite ||
      this == removeWatchLater ||
      this == removeFromWatched;
}

/// The actions a row in [tab] offers for [entry], in order: first the way to
/// watch/edit it, then the toggle of the list that isn't the tab's own, and
/// last the red removal from the tab's own list.
List<EntryAction> entryActionsFor(LibraryTab tab, UserMediaEntry entry) {
  final watch = entry.isWatched
      ? EntryAction.editWatched
      : EntryAction.markWatched;
  final favorite = entry.isFavorite
      ? EntryAction.removeFavorite
      : EntryAction.addFavorite;
  final watchLater = entry.isWatchLater
      ? EntryAction.removeWatchLater
      : EntryAction.addWatchLater;
  return switch (tab) {
    LibraryTab.favorites => [watch, watchLater, EntryAction.removeFavorite],
    LibraryTab.watchLater => [watch, favorite, EntryAction.removeWatchLater],
    LibraryTab.watched => [watch, favorite, EntryAction.removeFromWatched],
  };
}

/// [entry] after a list toggle ([EntryAction.addFavorite] and the like); the
/// actions that open H2 or remove aren't toggles and return [entry] itself.
UserMediaEntry applyTo(UserMediaEntry entry, EntryAction action) =>
    switch (action) {
      EntryAction.addFavorite => entry.copyWith(isFavorite: true),
      EntryAction.removeFavorite => entry.copyWith(isFavorite: false),
      EntryAction.addWatchLater => entry.copyWith(isWatchLater: true),
      EntryAction.removeWatchLater => entry.copyWith(isWatchLater: false),
      EntryAction.markWatched ||
      EntryAction.editWatched ||
      EntryAction.removeFromWatched => entry,
    };

/// [entry] with [tab]'s own mark taken off — or `null` when that leaves it in
/// no list at all (not a favorite, not for later, not watched), in which case
/// the entry should be deleted rather than kept empty.
UserMediaEntry? withoutIn(LibraryTab tab, UserMediaEntry entry) {
  final left = switch (tab) {
    LibraryTab.favorites => entry.copyWith(isFavorite: false),
    LibraryTab.watchLater => entry.copyWith(isWatchLater: false),
    LibraryTab.watched => entry.unmarkWatched(),
  };
  final inAList = left.isFavorite || left.isWatchLater || left.isWatched;
  return inAList ? left : null;
}
