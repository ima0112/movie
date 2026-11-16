import 'package:flutter/material.dart';

import '../../../../core/domain/entities/user_media_entry.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../shared/widgets/library_row.dart';
import '../../../../shared/widgets/library_row_status.dart';
import '../entry_actions.dart';

/// Wires [LibraryRow]'s swipe to B4's behavior (`docs/SCREENS.md` B4: "Swipe
/// left → delete, with an 'Undo' snackbar for 4 s, no dialog" — the only swipe
/// direction): it takes [entry] out of [tab]'s list through [removeFromTab],
/// talking to [UserLibraryRepository] directly, like `MovieActionRow` does
/// (CLAUDE.md rule 10).
class LibraryRowSwipeable extends StatelessWidget {
  const LibraryRowSwipeable({
    super.key,
    required this.entry,
    required this.tab,
    required this.userLibraryRepository,
    required this.posterUrl,
    required this.title,
    required this.metadata,
    this.status,
    this.onMore,
    this.onTap,
    this.onLongPress,
  });

  final UserMediaEntry entry;
  final LibraryTab tab;
  final UserLibraryRepository userLibraryRepository;

  final String? posterUrl;
  final String title;
  final String metadata;
  final LibraryRowStatus? status;
  final VoidCallback? onMore;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return LibraryRow(
      posterUrl: posterUrl,
      title: title,
      metadata: metadata,
      status: status,
      onMore: onMore,
      onTap: onTap,
      onLongPress: onLongPress,
      onDelete: () => removeFromTab(
        context,
        entry: entry,
        tab: tab,
        repository: userLibraryRepository,
      ),
    );
  }
}
