import '../entities/genre.dart';
import '../entities/media_type.dart';
import '../entities/user_media_entry.dart';
import 'library_stats.dart';
import 'viewer_label.dart';

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
  final ofType = entries
      .where((e) => filterType == null || e.key.type == filterType)
      .toList();
  final watched = ofType.where((e) => e.isWatched).toList();

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

  final genreTotal = genreCounts.values.fold<int>(0, (a, b) => a + b);
  final ranked = topGenres(genreCounts);
  final recent = [...watched]
    ..sort((a, b) => b.watchedAt!.compareTo(a.watchedAt!));

  return LibraryStats(
    moviesWatched: movies.length,
    tvShowsWatched: tvShows.length,
    movieHours: movieMinutes / 60,
    estimatedTvHours: tvMinutes / 60,
    averageRating: averageRating,
    topGenres: ranked,
    mostWatchedYear: _mostWatchedYear(watched),
    monthlyActivity: _monthlyActivity(watched, effectiveNow),
    genreTotal: genreTotal,
    recentlyWatched: recent.take(LibraryStats.recentlyWatchedLimit).toList(),
    weeklyStreak: weeklyStreak(watched, effectiveNow),
    favoritesCount: ofType.where((e) => e.isFavorite).length,
    watchLaterCount: ofType.where((e) => e.isWatchLater).length,
    viewerLabel: viewerLabelFor(
      watched,
      topGenre: ranked.isEmpty ? null : ranked.first.$1,
      genreShare: genreTotal == 0 ? 0 : ranked.first.$2 / genreTotal,
    ),
  );
}

/// Consecutive Monday-to-Sunday weeks with at least one entry watched, ending
/// at [now]'s week — or at the week before when this one has none yet (so a
/// streak survives until the week is over). 0 when neither has any.
int weeklyStreak(List<UserMediaEntry> watched, DateTime now) {
  DateTime weekOf(DateTime d) =>
      DateTime(d.year, d.month, d.day - (d.weekday - DateTime.monday));
  final weeks = {for (final e in watched) weekOf(e.watchedAt!)};
  var week = weekOf(now);
  if (!weeks.contains(week)) {
    week = DateTime(week.year, week.month, week.day - 7);
  }
  var streak = 0;
  while (weeks.contains(week)) {
    streak++;
    week = DateTime(week.year, week.month, week.day - 7);
  }
  return streak;
}

/// Ranks genres by watch count, most-watched first — ties broken by
/// [Genre.id] for a stable, deterministic order (rather than whatever
/// order a `Map` happens to iterate in). Domain code — never a display
/// name (CLAUDE.md rule 15), so the tie-break is the id, not a
/// locale-dependent name. Takes raw counts rather than entries so it
/// stays independently testable against synthetic data, decoupled from
/// how [calculateLibraryStats] tallies [UserMediaEntry.genres].
List<(Genre, int)> topGenres(Map<Genre, int> counts, {int limit = 5}) {
  final ranked = counts.entries.toList()
    ..sort((a, b) {
      final byCount = b.value.compareTo(a.value);
      return byCount != 0 ? byCount : a.key.id.compareTo(b.key.id);
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
