import '../core/domain/entities/user_media_entry.dart';
import '../core/domain/repositories/user_library_repository.dart';
import 'app_localizations.dart';
import 'library_tab_localization.dart';

/// The snackbar texts of a change to My List — CLAUDE.md rule 15.
extension LibraryFeedbackLocalization on AppLocalizations {
  /// What a Favorites / Watch later toggle did: "Dune added to Favorites",
  /// "Dune removed from Watch later". `null` when neither flag flipped
  /// ([before] is `null` when the title wasn't in My List at all).
  String? toggleMessage(UserMediaEntry? before, UserMediaEntry after) {
    final title = after.title;
    final wasFavorite = before?.isFavorite ?? false;
    final wasWatchLater = before?.isWatchLater ?? false;
    if (wasFavorite != after.isFavorite) {
      final tab = LibraryTab.favorites.localizedLabel(this);
      return after.isFavorite
          ? libraryAddedToTab(title, tab)
          : myListRemovedFromTab(title, tab);
    }
    if (wasWatchLater != after.isWatchLater) {
      final tab = LibraryTab.watchLater.localizedLabel(this);
      return after.isWatchLater
          ? libraryAddedToTab(title, tab)
          : myListRemovedFromTab(title, tab);
    }
    return null;
  }

  /// H2's "Save": "Dune marked as watched", plus "· Removed from Watch later"
  /// when it was there (marking watched takes it out). `null` when it was
  /// already watched (the user only edited the rating or date).
  String? markedWatchedMessage(UserMediaEntry? before, UserMediaEntry after) {
    if (before?.isWatched ?? false) return null;
    return (before?.isWatchLater ?? false)
        ? libraryMarkedWatchedLeftWatchLater(after.title)
        : libraryMarkedWatched(after.title);
  }
}
