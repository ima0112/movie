import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/domain/entities/user_media_entry.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../shared/widgets/library_row.dart';
import '../entry_actions.dart';

/// Wires up [LibraryRow]'s swipe callbacks to B4's actual behavior
/// (`docs/SCREENS.md` B4: "Swipe left → 'Remove' (red, snackbar with
/// 'Undo' for 4 s, no dialog); swipe right → 'Watched' (amber → H2) in
/// Favorites/Watch later, 'Favorite' in Watched.").
///
/// [LibraryRow] itself only knows how to reveal a colored background on
/// swipe (via `Dismissible`) and report which direction fired — it has
/// no idea what "remove" or "watched" mean. This widget is that meaning:
/// it holds the [entry] and [tab] needed to decide what a swipe does and
/// talks to [UserLibraryRepository] directly, the same way
/// `MovieActionRow` does (CLAUDE.md rule 10).
class LibraryRowSwipeable extends StatelessWidget {
  const LibraryRowSwipeable({
    super.key,
    required this.entry,
    required this.tab,
    required this.userLibraryRepository,
    required this.posterUrl,
    required this.title,
    required this.metadata,
    required this.trailing,
    this.onTap,
    this.onLongPress,
    this.onNeedsMarkWatched,
  });

  final UserMediaEntry entry;
  final LibraryTab tab;
  final UserLibraryRepository userLibraryRepository;

  final String? posterUrl;
  final String title;
  final String metadata;
  final LibraryRowTrailing trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Favorites/Watch later swipe-right → H2 (`MarkAsWatchedSheet`,
  /// `shared/widgets/mark_as_watched_sheet.dart`) — called instead of an
  /// instant toggle so the caller can open it; not wired up from here
  /// yet (a separate follow-up — this callback is currently unused).
  /// Ignored in the Watched tab, which toggles Favorite directly (no
  /// sheet needed for that).
  final VoidCallback? onNeedsMarkWatched;

  @override
  Widget build(BuildContext context) {
    return LibraryRow(
      posterUrl: posterUrl,
      title: title,
      metadata: metadata,
      trailing: trailing,
      onTap: onTap,
      onLongPress: onLongPress,
      onSwipeLeft: () => _remove(context),
      onSwipeRight: _swipeRight,
    );
  }

  void _swipeRight() {
    if (tab == LibraryTab.watched) {
      unawaited(
        userLibraryRepository.upsert(
          entry.copyWith(isFavorite: !entry.isFavorite),
        ),
      );
    } else {
      onNeedsMarkWatched?.call();
    }
  }

  void _remove(BuildContext context) => removeFromTab(
    context,
    entry: entry,
    tab: tab,
    repository: userLibraryRepository,
  );
}
