import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/user_media_entry.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../shared/widgets/media_card.dart';

/// One hero card's save button: toggles the title in **Watch later** for
/// real, through `UserLibraryRepository` (the same list D1/D2's Watch later
/// button and B4 use — `docs/SCREENS.md` B1: "save → Watch later").
///
/// Subscribes to just this title's entry, mapped down to "is it in Watch
/// later" and `.distinct()`-ed, so tapping it (or another card's) only
/// rebuilds this 36 px circle, never the card it sits on or the carousel
/// around it (CLAUDE.md rule 9, same pattern as D1's action row; rule 10 —
/// no library-wide copy). The stream is created once per card.
class DiscoverHeroSaveButton extends StatefulWidget {
  const DiscoverHeroSaveButton({
    super.key,
    required this.item,
    required this.userLibraryRepository,
  });

  final MediaItem item;
  final UserLibraryRepository userLibraryRepository;

  @override
  State<DiscoverHeroSaveButton> createState() => _DiscoverHeroSaveButtonState();
}

class _DiscoverHeroSaveButtonState extends State<DiscoverHeroSaveButton> {
  late final Stream<UserMediaEntry?> _entries = widget.userLibraryRepository
      .watchEntry(widget.item.key)
      .asBroadcastStream();
  late final Stream<bool> _isSaved = _entries
      .map((entry) => entry?.isWatchLater ?? false)
      .distinct();

  /// The latest stored entry, kept by one subscription for the card's life
  /// (a broadcast stream doesn't replay, so a tap can't ask it again).
  UserMediaEntry? _latest;
  late final StreamSubscription<UserMediaEntry?> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = _entries.listen((entry) => _latest = entry);
  }

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }

  Future<void> _toggle() async {
    final item = widget.item;
    // Always starts from what is stored, so favorite / watched / rating on
    // the same title are kept.
    final current = _latest;
    final snapshot = catalogSnapshotFrom(item);
    final base =
        current ?? UserMediaEntry(key: item.key, title: snapshot.title);
    await widget.userLibraryRepository.upsert(
      base.copyWith(
        isWatchLater: !base.isWatchLater,
        title: snapshot.title,
        genres: snapshot.genres,
        posterUrl: snapshot.posterUrl,
        voteAverage: snapshot.voteAverage,
        year: snapshot.year,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _isSaved,
      builder: (context, snapshot) => MediaCardSaveButton(
        isSaved: snapshot.data ?? false,
        onTap: () => unawaited(_toggle()),
      ),
    );
  }
}
