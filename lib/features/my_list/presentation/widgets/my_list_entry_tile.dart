import 'package:flutter/material.dart';

import '../../../../app/router.dart';
import '../../../../core/domain/entities/media_detail.dart';
import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/domain/entities/result.dart';
import '../../../../core/domain/entities/user_media_entry.dart';
import '../../../../core/domain/repositories/media_repository.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/media_type_localization.dart';
import '../../../../shared/widgets/library_row.dart';
import 'library_row_swipeable.dart';

/// One My List row (`docs/SCREENS.md` B4) — fetches [entry]'s display
/// data (title, poster, metadata line) via `MediaRepository.detail`,
/// since `UserMediaEntry` itself only carries the favorite/watch-later/
/// watched flags, not a catalog snapshot.
///
/// Two known simplifications, both against existing limits rather than
/// new ones: this refetches full detail (cast, crew, videos...) per row
/// just to read a handful of fields, and D2 (TV show detail) isn't
/// implemented yet, so a TV show entry falls back to a generic label
/// instead of "Removed" data from the fake repository (`_movies` isn't
/// where TV shows live). Favorites/Watch later show a chevron instead of
/// B4's "relative date saved" — `UserMediaEntry` has no such timestamp
/// yet (only `watchedAt`, Watched-only). Watched shows both stars and
/// date via `LibraryRowTrailing.starsWithDate`.
class MyListEntryTile extends StatelessWidget {
  const MyListEntryTile({
    super.key,
    required this.entry,
    required this.tab,
    required this.mediaRepository,
    required this.userLibraryRepository,
  });

  final UserMediaEntry entry;
  final LibraryTab tab;
  final MediaRepository mediaRepository;
  final UserLibraryRepository userLibraryRepository;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Result<MediaDetail>>(
      future: mediaRepository.detail(entry.key),
      builder: (context, snapshot) {
        final result = snapshot.data;
        final detail = result is Success<MediaDetail> ? result.value : null;

        return LibraryRowSwipeable(
          entry: entry,
          tab: tab,
          userLibraryRepository: userLibraryRepository,
          posterUrl: detail?.item.posterUrl,
          title: detail?.item.title ?? _fallbackTitle(context.l10n),
          metadata: detail == null ? '' : _metadata(detail, context.l10n),
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
      },
    );
  }

  String _fallbackTitle(AppLocalizations l10n) => switch (entry.key.type) {
    MediaType.movie => l10n.myListFallbackTitleMovie(entry.key.tmdbId),
    MediaType.tvShow => l10n.myListFallbackTitleTvShow(entry.key.tmdbId),
  };

  static String _metadata(MediaDetail detail, AppLocalizations l10n) {
    final year = switch (detail) {
      MovieDetail(:final releaseDate) => releaseDate?.year,
      TvShowDetail(:final firstAirDate) => firstAirDate?.year,
    };
    final typeLabel = detail.item.type.localizedSingular(l10n);
    final extra = switch (detail) {
      MovieDetail(:final runtimeMinutes) =>
        runtimeMinutes == null ? null : _formatRuntime(runtimeMinutes),
      TvShowDetail(:final seasons) =>
        '${seasons.length} season${seasons.length == 1 ? '' : 's'}',
    };
    return [if (year != null) '$year', typeLabel, ?extra].join(' · ');
  }

  static String _formatRuntime(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return h > 0 ? '$h h $m min' : '$m min';
  }
}
