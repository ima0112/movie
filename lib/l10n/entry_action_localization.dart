import '../features/my_list/domain/entry_action.dart';
import 'app_localizations.dart';

/// The row label of each [EntryAction] — CLAUDE.md rule 15.
extension EntryActionLocalization on EntryAction {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    EntryAction.markWatched => l10n.myListActionMarkWatched,
    EntryAction.editWatched => l10n.myListActionEditWatched,
    EntryAction.addFavorite => l10n.myListActionAddFavorite,
    EntryAction.removeFavorite => l10n.myListActionRemoveFavorite,
    EntryAction.addWatchLater => l10n.myListActionAddWatchLater,
    EntryAction.removeWatchLater => l10n.myListActionRemoveWatchLater,
    EntryAction.removeFromWatched => l10n.myListActionRemoveWatched,
  };
}
