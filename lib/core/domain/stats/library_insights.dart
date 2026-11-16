import '../entities/genre.dart';
import '../entities/user_media_entry.dart';
import 'stats_period.dart';

/// What one bar of [ActivitySeries] stands for.
enum ActivityUnit { month, day }

/// How many titles were watched in each bucket of a period, oldest first: the
/// 12 months ending now (all time), the 12 months of this year, or the days of
/// this month. [start] is the first bucket's date (the 1st of its month, or the
/// day itself).
class ActivitySeries {
  const ActivitySeries({
    required this.unit,
    required this.start,
    required this.counts,
  });

  final ActivityUnit unit;
  final DateTime start;
  final List<int> counts;
}

/// The month with the most titles watched.
class BusiestMonth {
  const BusiestMonth({
    required this.year,
    required this.month,
    required this.count,
  });

  final int year;
  final int month;
  final int count;
}

/// A title with the minutes it takes (a movie's runtime; a show's whole
/// estimated length).
class LongestTitle {
  const LongestTitle({required this.entry, required this.minutes});

  final UserMediaEntry entry;
  final int minutes;
}

/// A title the user rated far from TMDB's score (both in stars, 1–5).
class RatingDisagreement {
  const RatingDisagreement({
    required this.entry,
    required this.userStars,
    required this.tmdbStars,
  });

  final UserMediaEntry entry;
  final int userStars;

  /// TMDB's 0–10 score halved onto the same 0–5 scale.
  final double tmdbStars;

  /// Positive when the user rated it higher than TMDB.
  double get difference => userStars - tmdbStars;
}

/// Everything C4 shows for a [period]: a pure value computed from the user's
/// library by `calculateInsights` — no Flutter, no network. Counts, hours,
/// ratings, genres, decades and the activity are over the titles **watched in
/// the period**; the streaks and the Watch later backlog are of the whole
/// library, whatever the period.
class LibraryInsights {
  const LibraryInsights({
    required this.period,
    required this.moviesWatched,
    required this.showsWatched,
    required this.movieHours,
    required this.tvHours,
    required this.episodesWatched,
    required this.activity,
    required this.dayCounts,
    required this.calendarStart,
    required this.calendarEnd,
    required this.busiestMonth,
    required this.currentStreakWeeks,
    required this.longestStreakWeeks,
    required this.longestMovie,
    required this.longestShow,
    required this.bestRated,
    required this.watchLaterCount,
    required this.watchLaterHours,
    required this.ratingCounts,
    required this.averageRating,
    required this.tmdbAverage,
    required this.ratingGap,
    required this.disagreements,
    required this.genres,
    required this.genreTotal,
    required this.decades,
    required this.completeCount,
    this.previousCount,
  });

  final StatsPeriod period;

  final int moviesWatched;
  final int showsWatched;
  int get watchedCount => moviesWatched + showsWatched;

  final double movieHours;

  /// The shows' estimated hours (`episodes × runtime`, 45 min when unknown).
  final double tvHours;
  double get totalHours => movieHours + tvHours;
  final int episodesWatched;

  /// The same period one step back (last month for "this month", last year for
  /// "this year"), for the hero's comparison; `null` for all time.
  final int? previousCount;

  final ActivitySeries activity;

  /// Titles watched per day (date-only keys) — the calendar's data — over
  /// [calendarStart]–[calendarEnd] (both date-only, inclusive).
  final Map<DateTime, int> dayCounts;
  final DateTime calendarStart;
  final DateTime calendarEnd;

  final BusiestMonth? busiestMonth;
  final int currentStreakWeeks;
  final int longestStreakWeeks;
  final LongestTitle? longestMovie;
  final LongestTitle? longestShow;

  /// The user's highest-rated title (the latest watched among ties).
  final UserMediaEntry? bestRated;

  /// Titles in Watch later not yet watched, and the hours they add up to (a
  /// title with no known duration adds nothing).
  final int watchLaterCount;
  final double watchLaterHours;

  /// How many ratings of 1, 2, 3, 4 and 5 stars.
  final List<int> ratingCounts;
  final double? averageRating;

  /// TMDB's average over the same rated titles, in stars; `null` with none.
  final double? tmdbAverage;

  /// How far the user rates from TMDB on average, in stars, over the titles
  /// that have both (positive = more generous); `null` with none.
  final double? ratingGap;

  /// The titles rated furthest from TMDB (by at least a star), widest first.
  final List<RatingDisagreement> disagreements;

  /// Every genre of the watched titles, most watched first (ties by id).
  final List<(Genre, int)> genres;
  final int genreTotal;

  /// Titles by release decade (2010 = the 2010s), oldest first.
  final List<(int, int)> decades;

  /// Watched titles with genres, a year and a duration all saved; the rest
  /// don't count in the genre / decade / hours figures.
  final int completeCount;
}
