import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/domain/entities/media_detail.dart';
import '../../../core/domain/entities/media_key.dart';
import '../../../core/domain/entities/user_media_entry.dart';
import '../../../core/domain/entities/video.dart';
import '../../../core/domain/repositories/user_library_repository.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_spacing.dart';
import '../app_buttons.dart';
import '../mark_as_watched_sheet.dart';
import 'media_action_button.dart';

/// D1/D2's Trailer button + the Favorite / Watch later / Watched row.
///
/// Source of truth: `docs/SCREENS.md` D1, reused unchanged by D2. Per
/// CLAUDE.md rule 10, subscribes directly to
/// `UserLibraryRepository.watchEntry(mediaKey)` instead of a My-List-wide
/// Cubit. [mediaDetail] (the sealed base, not a movie-specific type)
/// supplies the trailer (`MediaDetail.trailer`'s own selection ladder
/// already works for either variant) and the genres a brand-new
/// `UserMediaEntry` needs — passed in as a plain value rather than read
/// from any screen-specific Cubit, which is what makes this widget
/// reusable by D2 without it (or this file) knowing that Cubit exists.
///
/// Favorite/Watch later/Watched each get their *own* `StreamBuilder`,
/// subscribed to `watchEntry(mediaKey)` mapped down to just the one
/// boolean each button renders and `.distinct()`-ed — tapping Favorite
/// only ever changes `isFavorite`, so only that mapped stream emits a
/// new value and only that button's `StreamBuilder` rebuilds (verified
/// with Flutter's widget-rebuild tracking: tapping one never shows the
/// other two as dirty). A single shared `StreamBuilder` around all
/// three (this file's previous shape) rebuilt every button on every
/// change, which technically still satisfied rule 9's ban on a
/// *screen*-wide rebuild, but not its stricter "a toggle rebuilds only
/// itself" line once three toggles share one row.
class MediaDetailActionRow extends StatefulWidget {
  const MediaDetailActionRow({
    super.key,
    required this.mediaKey,
    required this.userLibraryRepository,
    required this.mediaDetail,
    this.onPlayTrailer,
    this.onSeeSimilar,
  });

  final MediaKey mediaKey;
  final UserLibraryRepository userLibraryRepository;
  final MediaDetail mediaDetail;

  /// No trailer → "See similar" scrolls there instead (SCREENS.md D1);
  /// the assembled screen owns that scroll.
  final void Function(Video trailer)? onPlayTrailer;
  final VoidCallback? onSeeSimilar;

  @override
  State<MediaDetailActionRow> createState() => _MediaDetailActionRowState();
}

class _MediaDetailActionRowState extends State<MediaDetailActionRow> {
  // One subscription, shared by the cache below and all three buttons'
  // own derived streams (`asBroadcastStream` so each `.map().distinct()`
  // downstream gets every event without re-querying the repository).
  late final Stream<UserMediaEntry?> _entryStream;
  late final StreamSubscription<UserMediaEntry?> _cacheSubscription;

  // Tap handlers need the *current full* entry (to `copyWith` it), not
  // just whichever single boolean triggered a rebuild — kept in sync by
  // the same stream every button already renders from, read
  // synchronously at tap time instead of awaiting a fresh one-shot query.
  UserMediaEntry? _latestEntry;

  @override
  void initState() {
    super.initState();
    _entryStream = widget.userLibraryRepository
        .watchEntry(widget.mediaKey)
        .asBroadcastStream();
    _cacheSubscription = _entryStream.listen((entry) => _latestEntry = entry);
  }

  @override
  void dispose() {
    unawaited(_cacheSubscription.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trailer = widget.mediaDetail.trailer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrimaryButton(
          label: trailer != null ? 'Trailer' : 'See similar',
          onTap: trailer != null
              ? () => widget.onPlayTrailer?.call(trailer)
              : widget.onSeeSimilar,
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _ToggleActionButton(
                entryStream: _entryStream,
                select: (entry) => entry?.isFavorite ?? false,
                iconOutline: AppIcons.favorite,
                iconFill: AppIcons.favoriteFill,
                label: 'Favorite',
                onTap: () =>
                    _toggle((e) => e.copyWith(isFavorite: !e.isFavorite)),
              ),
            ),
            Expanded(
              child: _ToggleActionButton(
                entryStream: _entryStream,
                select: (entry) => entry?.isWatchLater ?? false,
                iconOutline: AppIcons.watchLater,
                iconFill: AppIcons.watchLaterFill,
                label: 'Watch later',
                onTap: () =>
                    _toggle((e) => e.copyWith(isWatchLater: !e.isWatchLater)),
              ),
            ),
            Expanded(
              child: _ToggleActionButton(
                entryStream: _entryStream,
                select: (entry) => entry?.isWatched ?? false,
                iconOutline: AppIcons.watched,
                iconFill: AppIcons.watchedFill,
                label: 'Watched',
                // Always opens H2 first, even when re-tapping an
                // already-watched entry (SCREENS.md D1) — never
                // upserts directly.
                onTap: _openMarkAsWatchedSheet,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _toggle(UserMediaEntry Function(UserMediaEntry) transform) {
    final current =
        _latestEntry ??
        UserMediaEntry(
          key: widget.mediaKey,
          title: widget.mediaDetail.item.title,
          genres: widget.mediaDetail.item.genres,
        );
    unawaited(widget.userLibraryRepository.upsert(transform(current)));
  }

  void _openMarkAsWatchedSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => MarkAsWatchedSheet(
        mediaKey: widget.mediaKey,
        userLibraryRepository: widget.userLibraryRepository,
        existingEntry: _latestEntry,
        mediaDetail: widget.mediaDetail,
      ),
    );
  }
}

/// One Favorite/Watch later/Watched button, rebuilding only when its
/// own [select]-ed boolean actually changes — see this file's own doc
/// comment for why that needs its own `.map().distinct()` stream rather
/// than sharing one `StreamBuilder` across all three buttons.
class _ToggleActionButton extends StatelessWidget {
  const _ToggleActionButton({
    required this.entryStream,
    required this.select,
    required this.iconOutline,
    required this.iconFill,
    required this.label,
    required this.onTap,
  });

  final Stream<UserMediaEntry?> entryStream;
  final bool Function(UserMediaEntry? entry) select;
  final IconData iconOutline;
  final IconData iconFill;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: entryStream.map(select).distinct(),
      builder: (context, snapshot) {
        return MediaActionButton(
          iconOutline: iconOutline,
          iconFill: iconFill,
          label: label,
          isActive: snapshot.data ?? false,
          onTap: onTap,
        );
      },
    );
  }
}
