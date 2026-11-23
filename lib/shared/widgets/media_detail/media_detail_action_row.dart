import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/domain/entities/media_detail.dart';
import '../../../core/domain/entities/media_key.dart';
import '../../../core/domain/entities/release_status.dart';
import '../../../core/domain/entities/user_media_entry.dart';
import '../../../core/domain/entities/video.dart';
import '../../../core/domain/repositories/user_library_repository.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../l10n/library_feedback_localization.dart';
import '../../../l10n/library_tab_localization.dart';
import '../../library_write.dart';
import '../app_buttons.dart';
import '../mark_as_watched_sheet.dart';
import '../media_detail_duration.dart';
import 'media_action_button.dart';

/// What the primary (white pill) button does.
enum PrimaryAction { trailer, similar, whereToWatch, none }

/// The first useful thing to offer: the trailer; without one, jump to the
/// similar titles; without those, to where to watch; with none of them the
/// button would lead nowhere, so there is none (`docs/SCREENS.md` D1).
PrimaryAction primaryActionFor({
  required bool hasTrailer,
  required bool hasSimilar,
  required bool hasWhereToWatch,
}) {
  if (hasTrailer) return PrimaryAction.trailer;
  if (hasSimilar) return PrimaryAction.similar;
  if (hasWhereToWatch) return PrimaryAction.whereToWatch;
  return PrimaryAction.none;
}

/// D1/D2's action row: the white Trailer pill and the Favorite / Watch later /
/// Watched circles, side by side.
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
    this.onSeeWhereToWatch,
  });

  final MediaKey mediaKey;
  final UserLibraryRepository userLibraryRepository;
  final MediaDetail mediaDetail;

  /// The primary button's fallbacks (see [primaryActionFor]): no trailer ->
  /// "See similar" (scrolls there), only offered when there are similar
  /// titles ([onSeeSimilar] `null` otherwise); neither -> "Where to watch"
  /// ([onSeeWhereToWatch] `null` when no service is listed); none of them ->
  /// no button at all.
  final void Function(Video trailer)? onPlayTrailer;
  final VoidCallback? onSeeSimilar;
  final VoidCallback? onSeeWhereToWatch;

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
    final l10n = context.l10n;
    // Not out yet: nothing to rate and nothing to have watched.
    final upcoming =
        widget.mediaDetail.releaseStatus?.stage == ReleaseStage.upcoming;
    final primary = primaryActionFor(
      hasTrailer: trailer != null,
      hasSimilar: widget.onSeeSimilar != null,
      hasWhereToWatch: widget.onSeeWhereToWatch != null,
    );
    final label = switch (primary) {
      PrimaryAction.trailer => l10n.mediaDetailActionTrailer,
      PrimaryAction.similar => l10n.mediaDetailActionSeeSimilar,
      _ => l10n.whereToWatchTitle,
    };
    final onTap = switch (primary) {
      PrimaryAction.trailer => () => widget.onPlayTrailer?.call(trailer!),
      PrimaryAction.similar => widget.onSeeSimilar,
      _ => widget.onSeeWhereToWatch,
    };
    List<Widget> toggles({required bool wide}) => [
      _ToggleActionButton(
        wide: wide,
        entryStream: _entryStream,
        select: (entry) => entry?.isFavorite ?? false,
        iconOutline: AppIcons.favorite,
        iconFill: AppIcons.favoriteFill,
        label: l10n.mediaDetailActionFavorite,
        onTap: () => _toggle((e) => e.copyWith(isFavorite: !e.isFavorite)),
      ),
      _watchLater(l10n, wide: wide),
      if (!upcoming)
        _ToggleActionButton(
          wide: wide,
          entryStream: _entryStream,
          select: (entry) => entry?.isWatched ?? false,
          iconOutline: AppIcons.watched,
          iconFill: AppIcons.watchedFill,
          label: LibraryTab.watched.localizedLabel(l10n),
          // Always opens H2 first, even when re-tapping an already-watched
          // entry (SCREENS.md D1) — never upserts directly.
          onTap: _openMarkAsWatchedSheet,
        ),
    ];
    final button = primary == PrimaryAction.none
        ? null
        : PrimaryButton(
            icon: primary == PrimaryAction.trailer ? AppIcons.play : null,
            label: label,
            onTap: onTap,
            height: MediaActionButton.size,
          );

    // At a large text scale the pill and the three circles don't fit side by
    // side: the pill gets its own row and the circles sit under it.
    final stacked =
        button != null && MediaQuery.textScalerOf(context).scale(1) >= 1.5;
    if (stacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          button,
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: toggles(wide: false),
          ),
        ],
      );
    }
    if (button == null) {
      // No pill: the toggles are equal rounded rectangles across the row.
      final wide = toggles(wide: true);
      return Row(
        children: [
          for (var i = 0; i < wide.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.md),
            Expanded(child: wide[i]),
          ],
        ],
      );
    }
    final circles = toggles(wide: false);
    return Row(
      children: [
        Expanded(child: button),
        const SizedBox(width: AppSpacing.md),
        for (var i = 0; i < circles.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.sm),
          circles[i],
        ],
      ],
    );
  }

  Widget _watchLater(AppLocalizations l10n, {required bool wide}) =>
      _ToggleActionButton(
        wide: wide,
        entryStream: _entryStream,
        select: (entry) => entry?.isWatchLater ?? false,
        iconOutline: AppIcons.watchLater,
        iconFill: AppIcons.watchLaterFill,
        label: LibraryTab.watchLater.localizedLabel(l10n),
        onTap: () => _toggle((e) => e.copyWith(isWatchLater: !e.isWatchLater)),
      );

  void _toggle(UserMediaEntry Function(UserMediaEntry) transform) {
    // Always re-stamps the catalog snapshot from what's already loaded
    // here, favorite/watch-later toggle or not — the same "capture
    // what's on hand" rule every other write site in this file's own
    // doc comment follows for genres.
    final snapshot = catalogSnapshotFrom(widget.mediaDetail.item);
    final duration = durationFieldsFrom(widget.mediaDetail);
    final current =
        (_latestEntry ??
                UserMediaEntry(key: widget.mediaKey, title: snapshot.title))
            .copyWith(
              title: snapshot.title,
              genres: snapshot.genres,
              posterUrl: snapshot.posterUrl,
              voteAverage: snapshot.voteAverage,
              year: snapshot.year,
              runtimeMinutes: duration.runtimeMinutes,
              episodeCount: duration.episodeCount,
              episodeRuntimeMinutes: duration.episodeRuntimeMinutes,
            );
    final next = transform(current);
    unawaited(
      saveEntry(
        context,
        widget.userLibraryRepository,
        next,
        previous: _latestEntry,
        message: context.l10n.toggleMessage(_latestEntry, next),
      ),
    );
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
    required this.wide,
  });

  final Stream<UserMediaEntry?> entryStream;
  final bool Function(UserMediaEntry? entry) select;
  final IconData iconOutline;
  final IconData iconFill;
  final String label;
  final VoidCallback onTap;

  /// A rounded rectangle for the no-trailer-button row, else a circle.
  final bool wide;

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
          wide: wide,
        );
      },
    );
  }
}
