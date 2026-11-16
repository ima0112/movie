import '../core/domain/repositories/user_library_repository.dart';
import 'app_localizations.dart';

/// The mappers from [LibraryTab] to display text — CLAUDE.md rule 15.
extension LibraryTabLocalization on LibraryTab {
  /// The tab's own label, e.g. "Favorites".
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    LibraryTab.favorites => l10n.myListTabFavorites,
    LibraryTab.watchLater => l10n.myListTabWatchLater,
    LibraryTab.watched => l10n.myListTabWatched,
  };

  /// The remove snackbar, e.g. "Dune removed from Favorites".
  String localizedRemovedMessage(AppLocalizations l10n, String title) =>
      l10n.myListRemovedFromTab(title, localizedLabel(l10n));

  /// The tab's own empty-state headline.
  String localizedEmptyHeadline(AppLocalizations l10n) => switch (this) {
    LibraryTab.favorites => l10n.myListEmptyFavoritesHeadline,
    LibraryTab.watchLater => l10n.myListEmptyWatchLaterHeadline,
    LibraryTab.watched => l10n.myListEmptyWatchedHeadline,
  };
}
