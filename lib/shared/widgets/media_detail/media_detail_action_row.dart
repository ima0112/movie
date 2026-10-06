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
class MediaDetailActionRow extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final trailer = mediaDetail.trailer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrimaryButton(
          label: trailer != null ? 'Trailer' : 'See similar',
          onTap: trailer != null
              ? () => onPlayTrailer?.call(trailer)
              : onSeeSimilar,
        ),
        const SizedBox(height: AppSpacing.lg),
        StreamBuilder<UserMediaEntry?>(
          stream: userLibraryRepository.watchEntry(mediaKey),
          builder: (context, snapshot) {
            final entry = snapshot.data;
            return Row(
              children: [
                Expanded(
                  child: MediaActionButton(
                    iconOutline: AppIcons.favorite,
                    iconFill: AppIcons.favoriteFill,
                    label: 'Favorite',
                    isActive: entry?.isFavorite ?? false,
                    onTap: () => _toggle(
                      entry,
                      (e) => e.copyWith(isFavorite: !e.isFavorite),
                    ),
                  ),
                ),
                Expanded(
                  child: MediaActionButton(
                    iconOutline: AppIcons.watchLater,
                    iconFill: AppIcons.watchLaterFill,
                    label: 'Watch later',
                    isActive: entry?.isWatchLater ?? false,
                    onTap: () => _toggle(
                      entry,
                      (e) => e.copyWith(isWatchLater: !e.isWatchLater),
                    ),
                  ),
                ),
                Expanded(
                  child: MediaActionButton(
                    iconOutline: AppIcons.watched,
                    iconFill: AppIcons.watchedFill,
                    label: 'Watched',
                    isActive: entry?.isWatched ?? false,
                    // Always opens H2 first, even when re-tapping an
                    // already-watched entry (SCREENS.md D1) — never
                    // upserts directly.
                    onTap: () => _openMarkAsWatchedSheet(context, entry),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _toggle(
    UserMediaEntry? entry,
    UserMediaEntry Function(UserMediaEntry) transform,
  ) {
    final current =
        entry ??
        UserMediaEntry(key: mediaKey, genres: mediaDetail.item.genres);
    unawaited(userLibraryRepository.upsert(transform(current)));
  }

  void _openMarkAsWatchedSheet(BuildContext context, UserMediaEntry? entry) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => MarkAsWatchedSheet(
        mediaKey: mediaKey,
        userLibraryRepository: userLibraryRepository,
        existingEntry: entry,
        mediaDetail: mediaDetail,
      ),
    );
  }
}
