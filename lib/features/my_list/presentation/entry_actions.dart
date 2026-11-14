import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/domain/entities/user_media_entry.dart';
import '../../../core/domain/repositories/user_library_repository.dart';
import '../../../core/theme/app_icons.dart';
import '../../../l10n/entry_action_localization.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../l10n/library_tab_localization.dart';
import '../../../l10n/media_type_localization.dart';
import '../../../shared/widgets/actions_sheet.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/widgets/mark_as_watched_sheet.dart';
import '../domain/entry_action.dart';

/// Everything a My List row can do to its entry, shared by the row's swipe,
/// its three-dot button and its long-press so they can't drift apart
/// (`docs/SCREENS.md` B4 and H1).

/// Opens H1 for [entry], with the actions [entryActionsFor] gives [tab].
Future<void> showEntryActions(
  BuildContext context, {
  required UserMediaEntry entry,
  required LibraryTab tab,
  required UserLibraryRepository repository,
}) {
  final l10n = context.l10n;
  final year = entry.year;
  return ActionsSheet.show(
    context,
    leading: ActionsSheet.posterSlot(
      entry.posterUrl == null
          ? null
          : Image.network(
              entry.posterUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
    ),
    title: entry.title,
    subtitle: [
      entry.key.type.localizedSingular(l10n),
      if (year != null) '$year',
    ].join(' · '),
    actions: [
      for (final action in entryActionsFor(tab, entry))
        SheetAction(
          icon: _iconOf(action),
          label: action.localizedLabel(l10n),
          destructive: action.isRemoval,
          // Runs after the sheet has closed, from the row's own context.
          onTap: () => _run(context, action, entry, tab, repository),
        ),
    ],
  );
}

void _run(
  BuildContext context,
  EntryAction action,
  UserMediaEntry entry,
  LibraryTab tab,
  UserLibraryRepository repository,
) {
  switch (action) {
    case EntryAction.markWatched || EntryAction.editWatched:
      showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        builder: (_) => MarkAsWatchedSheet(
          mediaKey: entry.key,
          userLibraryRepository: repository,
          existingEntry: entry,
        ),
      );
    case EntryAction.removeFavorite ||
        EntryAction.removeWatchLater ||
        EntryAction.removeFromWatched:
      removeFromTab(context, entry: entry, tab: tab, repository: repository);
    case EntryAction.addFavorite || EntryAction.addWatchLater:
      unawaited(repository.upsert(applyTo(entry, action)));
  }
}

IconData _iconOf(EntryAction action) => switch (action) {
  EntryAction.markWatched || EntryAction.editWatched => AppIcons.watched,
  EntryAction.addFavorite || EntryAction.removeFavorite => AppIcons.favorite,
  EntryAction.addWatchLater ||
  EntryAction.removeWatchLater => AppIcons.watchLater,
  EntryAction.removeFromWatched => AppIcons.delete,
};

/// Takes [entry] out of [tab]'s list (deleting it when that leaves it in no
/// list) and offers "Undo" in a snackbar for 4 s: swipe-to-remove and the
/// sheet's red row both come here.
void removeFromTab(
  BuildContext context, {
  required UserMediaEntry entry,
  required LibraryTab tab,
  required UserLibraryRepository repository,
}) {
  final l10n = context.l10n;
  final left = withoutIn(tab, entry);
  unawaited(
    left == null ? repository.remove(entry.key) : repository.upsert(left),
  );
  AppSnackBar.show(
    context,
    tab.localizedRemovedMessage(l10n, entry.title),
    actionLabel: l10n.myListUndoAction,
    onAction: () => unawaited(repository.upsert(entry)),
  );
}
