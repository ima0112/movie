import '../../../core/domain/entities/genre.dart';
import '../../../core/domain/entities/media_type.dart';
import '../../../core/domain/entities/user_media_entry.dart';
import 'library_stats.dart';

/// Computes [LibraryStats] purely from a list of [UserMediaEntry] — no
/// Flutter, no repository, no network. See `docs/SCREENS.md` C4.
///
/// [filterType] mirrors C4's "All · Movies · TV Shows" chips: when set,
/// every field is computed only over entries of that type — a "Movies"
/// filter naturally zeroes `tvShowsWatched`/`estimatedTvHours` rather
/// than needing special-casing, since that's what the chip means ("show
/// me only movie stats").
///
/// [now] anchors "the last 12 months" for
/// [LibraryStats.monthlyActivity] — defaults to [DateTime.now] in
/// production; tests pass a fixed value so the 12-month window (and the
/// whole result) is deterministic.
///
/// [LibraryStats.topGenres] counts each watched entry's
/// [UserMediaEntry.genres] once per genre it lists. An entry saved
/// before that field existed simply has `genres: []` and doesn't
/// contribute — not an error, just an undercount for old data, same as
/// the duration fields above.
LibraryStats calculateLibraryStats(
  List<UserMediaEntry> entries, {
  MediaType? filterType,
  DateTime? now,
}) {
  final effectiveNow = now ?? DateTime.now();
  final watched = entries
      .where((e) => filterType == null || e.key.type == filterType)
      .where((e) => e.isWatched)
      .toList();

  final movies = watched.where((e) => e.key.type == MediaType.movie);
  final tvShows = watched.where((e) => e.key.type == MediaType.tvShow);

  final movieMinutes = movies.fold<int>(
    0,
    (sum, e) => sum + (e.runtimeMinutes ?? 0),
  );
  // `episodeCount ?? 0` zeroes the whole product for an entry that never
  // had it populated, regardless of the 45-min fallback below — the
  // fallback only ever affects a show whose episode *count* is known but
  // whose per-episode runtime isn't.
  final tvMinutes = tvShows.fold<int>(
    0,
    (sum, e) => sum + (e.episodeCount ?? 0) * (e.episodeRuntimeMinutes ?? 45),
  );

  final ratings = watched.map((e) => e.rating).whereType<int>().toList();
  final averageRating = ratings.isEmpty
      ? null
      : ratings.reduce((a, b) => a + b) / ratings.length;

  final genreCounts = <Genre, int>{};
  for (final entry in watched) {
    for (final genre in entry.genres) {
      genreCounts[genre] = (genreCounts[genre] ?? 0) + 1;
    }
  }

  return LibraryStats(
    moviesWatched: movies.length,
    tvShowsWatched: tvShows.length,
    movieHours: movieMinutes / 60,
    estimatedTvHours: tvMinutes / 60,
    averageRating: averageRating,
    topGenres: topGenres(genreCounts),
    mostWatchedYear: _mostWatchedYear(watched),
    monthlyActivity: _monthlyActivity(watched, effectiveNow),
  );
}

/// Ranks genres by watch count, most-watched first — ties broken
/// alphabetically by name for a stable, deterministic order (rather
/// than whatever order a `Map` happens to iterate in). Takes raw counts
/// rather than entries so it stays independently testable against
/// synthetic data, decoupled from how [calculateLibraryStats] tallies
/// [UserMediaEntry.genres].
List<(Genre, int)> topGenres(Map<Genre, int> counts, {int limit = 5}) {
  final ranked = counts.entries.toList()
    ..sort((a, b) {
      final byCount = b.value.compareTo(a.value);
      return byCount != 0 ? byCount : a.key.name.compareTo(b.key.name);
    });
  return ranked.take(limit).map((e) => (e.key, e.value)).toList();
}

/// The watch-date year with the most entries — ties broken by the more
/// recent year (an explicit, documented rule rather than "whichever a
/// map's iteration order visits last").
int? _mostWatchedYear(List<UserMediaEntry> watched) {
  if (watched.isEmpty) return null;
  final counts = <int, int>{};
  for (final entry in watched) {
    final year = entry.watchedAt!.year;
    counts[year] = (counts[year] ?? 0) + 1;
  }
  var bestYear = counts.keys.first;
  var bestCount = 0;
  for (final MapEntry(key: year, value: count) in counts.entries) {
    if (count > bestCount || (count == bestCount && year > bestYear)) {
      bestYear = year;
      bestCount = count;
    }
  }
  return bestYear;
}

/// 12 counts, oldest first, ending at [now]'s month — entries watched
/// outside that trailing 12-month window don't contribute at all.
List<int> _monthlyActivity(List<UserMediaEntry> watched, DateTime now) {
  final counts = List<int>.filled(12, 0);
  for (final entry in watched) {
    final watchedAt = entry.watchedAt!;
    final monthsAgo =
        (now.year - watchedAt.year) * 12 + (now.month - watchedAt.month);
    if (monthsAgo >= 0 && monthsAgo < 12) {
      counts[11 - monthsAgo]++;
    }
  }
  return counts;
}
