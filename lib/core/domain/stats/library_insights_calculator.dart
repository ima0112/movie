import '../entities/genre.dart';
import '../entities/media_type.dart';
import '../entities/user_media_entry.dart';
import 'library_insights.dart';
import 'library_stats_calculator.dart' show weeklyStreak;
import 'stats_period.dart';

/// A show's length when its episode runtime isn't known.
const int _defaultEpisodeMinutes = 45;

/// How many weeks the all-time calendar shows.
const int calendarWeeks = 26;

/// How many disagreements C4 lists.
const int maxDisagreements = 3;

/// Computes C4's [LibraryInsights] for [period] from the user's [entries] —
/// pure, no Flutter, no network. [now] anchors "this month", "this year" and
/// the trailing windows (today unless a test says so).
LibraryInsights calculateInsights(
  List<UserMediaEntry> entries, {
  required StatsPeriod period,
  DateTime? now,
}) {
  final today = now ?? DateTime.now();
  final watchedAll = entries.where((e) => e.isWatched).toList();
  final watched = [
    for (final e in watchedAll)
      if (period.contains(e.watchedAt!, today)) e,
  ];
  final movies = watched.where((e) => e.key.type == MediaType.movie);
  final shows = watched.where((e) => e.key.type == MediaType.tvShow);

  final ratings = <int>[for (final e in watched) ?e.rating];
  final paired = [
    for (final e in watched)
      if (e.rating != null && (e.voteAverage ?? 0) > 0) e,
  ];
  final gaps = [for (final e in paired) e.rating! - e.voteAverage! / 2];

  final genreCounts = <Genre, int>{};
  final decadeCounts = <int, int>{};
  for (final e in watched) {
    for (final g in e.genres) {
      genreCounts[g] = (genreCounts[g] ?? 0) + 1;
    }
    final year = e.year;
    if (year != null) {
      decadeCounts[(year ~/ 10) * 10] =
          (decadeCounts[(year ~/ 10) * 10] ?? 0) + 1;
    }
  }
  final rankedGenres = genreCounts.entries.toList()
    ..sort((a, b) {
      final byCount = b.value.compareTo(a.value);
      return byCount != 0 ? byCount : a.key.id.compareTo(b.key.id);
    });

  final calendar = _calendarRange(period, today);
  final backlog = entries.where((e) => e.isWatchLater && !e.isWatched);

  return LibraryInsights(
    period: period,
    moviesWatched: movies.length,
    showsWatched: shows.length,
    movieHours: movies.fold<int>(0, (s, e) => s + (e.runtimeMinutes ?? 0)) / 60,
    tvHours: shows.fold<int>(0, (s, e) => s + _showMinutes(e)) / 60,
    episodesWatched: shows.fold<int>(0, (s, e) => s + (e.episodeCount ?? 0)),
    previousCount: _previousCount(watchedAll, period, today),
    activity: _activity(watched, period, today),
    dayCounts: _dayCounts(watched),
    calendarStart: calendar.$1,
    calendarEnd: calendar.$2,
    busiestMonth: _busiestMonth(watched),
    currentStreakWeeks: weeklyStreak(watchedAll, today),
    longestStreakWeeks: _longestStreak(watchedAll),
    longestMovie: _longest(movies, (e) => e.runtimeMinutes),
    longestShow: _longest(
      shows.where((e) => e.episodeCount != null),
      _showMinutes,
    ),
    bestRated: _bestRated(watched),
    watchLaterCount: backlog.length,
    watchLaterHours: backlog.fold<int>(0, (s, e) => s + _titleMinutes(e)) / 60,
    ratingCounts: [
      for (var stars = 1; stars <= 5; stars++)
        ratings.where((r) => r == stars).length,
    ],
    averageRating: ratings.isEmpty
        ? null
        : ratings.reduce((a, b) => a + b) / ratings.length,
    tmdbAverage: paired.isEmpty
        ? null
        : paired.fold<double>(0, (s, e) => s + e.voteAverage! / 2) /
              paired.length,
    ratingGap: gaps.isEmpty ? null : gaps.reduce((a, b) => a + b) / gaps.length,
    disagreements: _disagreements(paired),
    genres: [for (final e in rankedGenres) (e.key, e.value)],
    genreTotal: genreCounts.values.fold<int>(0, (a, b) => a + b),
    decades:
        (decadeCounts.entries.toList()..sort((a, b) => a.key.compareTo(b.key)))
            .map((e) => (e.key, e.value))
            .toList(),
    completeCount: watched
        .where(
          (e) =>
              e.genres.isNotEmpty &&
              e.year != null &&
              (e.runtimeMinutes != null || e.episodeCount != null),
        )
        .length,
  );
}

/// A show's whole estimated length in minutes.
int _showMinutes(UserMediaEntry e) =>
    (e.episodeCount ?? 0) * (e.episodeRuntimeMinutes ?? _defaultEpisodeMinutes);

int _titleMinutes(UserMediaEntry e) =>
    e.key.type == MediaType.movie ? (e.runtimeMinutes ?? 0) : _showMinutes(e);

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

Map<DateTime, int> _dayCounts(List<UserMediaEntry> watched) {
  final counts = <DateTime, int>{};
  for (final e in watched) {
    final day = _day(e.watchedAt!);
    counts[day] = (counts[day] ?? 0) + 1;
  }
  return counts;
}

/// The calendar's first and last day for [period] (both date-only).
(DateTime, DateTime) _calendarRange(StatsPeriod period, DateTime now) {
  final today = _day(now);
  return switch (period) {
    StatsPeriod.thisMonth => (
      DateTime(now.year, now.month, 1),
      DateTime(now.year, now.month + 1, 0),
    ),
    StatsPeriod.thisYear => (
      DateTime(now.year, 1, 1),
      DateTime(now.year, 12, 31),
    ),
    StatsPeriod.allTime => (
      // The Monday of the week `calendarWeeks - 1` weeks back.
      DateTime(
        today.year,
        today.month,
        today.day - (today.weekday - DateTime.monday) - 7 * (calendarWeeks - 1),
      ),
      today,
    ),
  };
}

ActivitySeries _activity(
  List<UserMediaEntry> watched,
  StatsPeriod period,
  DateTime now,
) {
  switch (period) {
    case StatsPeriod.thisMonth:
      final days = DateTime(now.year, now.month + 1, 0).day;
      final counts = List<int>.filled(days, 0);
      for (final e in watched) {
        counts[e.watchedAt!.day - 1]++;
      }
      return ActivitySeries(
        unit: ActivityUnit.day,
        start: DateTime(now.year, now.month, 1),
        counts: counts,
      );
    case StatsPeriod.thisYear:
      final counts = List<int>.filled(12, 0);
      for (final e in watched) {
        counts[e.watchedAt!.month - 1]++;
      }
      return ActivitySeries(
        unit: ActivityUnit.month,
        start: DateTime(now.year, 1, 1),
        counts: counts,
      );
    case StatsPeriod.allTime:
      final counts = List<int>.filled(12, 0);
      for (final e in watched) {
        final monthsAgo =
            (now.year - e.watchedAt!.year) * 12 +
            (now.month - e.watchedAt!.month);
        if (monthsAgo >= 0 && monthsAgo < 12) counts[11 - monthsAgo]++;
      }
      return ActivitySeries(
        unit: ActivityUnit.month,
        start: DateTime(now.year, now.month - 11, 1),
        counts: counts,
      );
  }
}

/// The count of the period before [period] (last year / last month); `null`
/// for all time.
int? _previousCount(
  List<UserMediaEntry> watchedAll,
  StatsPeriod period,
  DateTime now,
) {
  bool inPrevious(DateTime d) => switch (period) {
    StatsPeriod.allTime => false,
    StatsPeriod.thisYear => d.year == now.year - 1,
    StatsPeriod.thisMonth =>
      d.year == DateTime(now.year, now.month - 1).year &&
          d.month == DateTime(now.year, now.month - 1).month,
  };
  return period == StatsPeriod.allTime
      ? null
      : watchedAll.where((e) => inPrevious(e.watchedAt!)).length;
}

BusiestMonth? _busiestMonth(List<UserMediaEntry> watched) {
  final counts = <(int, int), int>{};
  for (final e in watched) {
    final key = (e.watchedAt!.year, e.watchedAt!.month);
    counts[key] = (counts[key] ?? 0) + 1;
  }
  BusiestMonth? best;
  for (final MapEntry(key: (year, month), value: count) in counts.entries) {
    // Ties go to the more recent month.
    final newer =
        best == null ||
        year > best.year ||
        (year == best.year && month > best.month);
    if (best == null || count > best.count || (count == best.count && newer)) {
      best = BusiestMonth(year: year, month: month, count: count);
    }
  }
  return best;
}

/// The longest run of consecutive Monday-to-Sunday weeks with a title watched.
int _longestStreak(List<UserMediaEntry> watchedAll) {
  DateTime weekOf(DateTime d) =>
      DateTime(d.year, d.month, d.day - (d.weekday - DateTime.monday));
  final weeks = {for (final e in watchedAll) weekOf(e.watchedAt!)}.toList()
    ..sort();
  var best = 0;
  var run = 0;
  DateTime? previous;
  for (final week in weeks) {
    final consecutive =
        previous != null &&
        DateTime(previous.year, previous.month, previous.day + 7) == week;
    run = consecutive ? run + 1 : 1;
    if (run > best) best = run;
    previous = week;
  }
  return best;
}

LongestTitle? _longest(
  Iterable<UserMediaEntry> candidates,
  int? Function(UserMediaEntry) minutes,
) {
  LongestTitle? best;
  for (final e in candidates) {
    final m = minutes(e);
    if (m == null || m <= 0) continue;
    if (best == null || m > best.minutes) {
      best = LongestTitle(entry: e, minutes: m);
    }
  }
  return best;
}

UserMediaEntry? _bestRated(List<UserMediaEntry> watched) {
  UserMediaEntry? best;
  for (final e in watched) {
    final rating = e.rating;
    if (rating == null) continue;
    if (best == null ||
        rating > best.rating! ||
        (rating == best.rating! && e.watchedAt!.isAfter(best.watchedAt!))) {
      best = e;
    }
  }
  return best;
}

List<RatingDisagreement> _disagreements(List<UserMediaEntry> paired) {
  final all =
      [
          for (final e in paired)
            RatingDisagreement(
              entry: e,
              userStars: e.rating!,
              tmdbStars: e.voteAverage! / 2,
            ),
        ].where((d) => d.difference.abs() >= 1).toList()
        ..sort((a, b) => b.difference.abs().compareTo(a.difference.abs()));
  return all.take(maxDisagreements).toList();
}
