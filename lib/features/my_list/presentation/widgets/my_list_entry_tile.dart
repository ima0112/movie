import 'package:flutter/material.dart';

import '../../../../app/router.dart';
import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/domain/entities/user_media_entry.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/media_type_localization.dart';
import '../../../../shared/widgets/library_row.dart';
import 'library_row_swipeable.dart';

/// One My List row (`docs/SCREENS.md` B4) — renders entirely from
/// [entry]'s own persisted catalog snapshot (title, poster, year, vote
/// average), with no network call: no `MediaRepository.detail` fetch,
/// unlike this widget's previous shape. The poster image itself still
/// loads by URL (`LibraryRow`'s own `Image.network`), with the same
/// placeholder it already shows for any missing/failed image — that's
/// image loading, not an extra API request for data this row needs.
///
/// Episode count/runtime are part of [entry]'s own snapshot, but — per
/// `UserMediaEntry`'s own doc comment — they're only ever captured
/// where a `MediaDetail` was on hand (D1/D2's toggle, H2's Save, the
/// detail screens' lazy refresh), never from E3's "Add to watch later"
/// alone. So the metadata line's third segment (duration/episode count)
/// simply doesn't appear until the entry has been through one of those,
/// rather than this row re-fetching just to show it.
class MyListEntryTile extends StatelessWidget {
  const MyListEntryTile({
    super.key,
    required this.entry,
    required this.tab,
    required this.userLibraryRepository,
  });

  final UserMediaEntry entry;
  final LibraryTab tab;
  final UserLibraryRepository userLibraryRepository;

  @override
  Widget build(BuildContext context) {
    return LibraryRowSwipeable(
      entry: entry,
      tab: tab,
      userLibraryRepository: userLibraryRepository,
      posterUrl: entry.posterUrl,
      title: entry.title.isEmpty ? _fallbackTitle(context.l10n) : entry.title,
      metadata: _metadata(entry, context.l10n),
      trailing: tab == LibraryTab.watched
          ? LibraryRowTrailing.starsWithDate(
              rating: entry.rating,
              // `watch(tab: .watched)` only ever returns watched
              // entries, so `watchedAt` is set — the fallback is
              // just defensive, not an expected path.
              watchedAt: entry.watchedAt ?? DateTime.now(),
            )
          : const LibraryRowTrailing.chevron(),
      onTap: () => context.pushMediaDetail(entry.key),
    );
  }

  String _fallbackTitle(AppLocalizations l10n) => switch (entry.key.type) {
    MediaType.movie => l10n.myListFallbackTitleMovie(entry.key.tmdbId),
    MediaType.tvShow => l10n.myListFallbackTitleTvShow(entry.key.tmdbId),
  };

  static String _metadata(UserMediaEntry entry, AppLocalizations l10n) {
    final typeLabel = entry.key.type.localizedSingular(l10n);
    final extra = switch (entry.key.type) {
      MediaType.movie =>
        entry.runtimeMinutes == null
            ? null
            : _formatRuntime(entry.runtimeMinutes!, l10n),
      MediaType.tvShow =>
        entry.episodeCount == null
            ? null
            : l10n.myListEpisodesCount(entry.episodeCount!),
    };
    return [
      if (entry.year != null) '${entry.year}',
      typeLabel,
      ?extra,
    ].join(' · ');
  }

  static String _formatRuntime(int minutes, AppLocalizations l10n) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return h > 0
        ? l10n.myListRuntimeHoursMinutes(h, m)
        : l10n.myListRuntimeMinutesOnly(m);
  }
}
