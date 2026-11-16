import '../entities/genre.dart';
import '../entities/user_media_entry.dart';
import 'viewer_label.dart';

/// The library-wide statistics C4 ("Stats") shows.
///
/// Source of truth: `docs/SCREENS.md` C4 — "Four metric cards in a 2×2
/// grid: Movies watched · Hours of movies · TV shows watched ·
/// Estimated TV hours. 'Genres you watch most'... 'Your most-watched
/// year'... 'Activity over the last 12 months'... 'Your average
/// rating'." A pure value object — see `library_stats_calculator.dart`
/// for how it's produced from a `UserMediaEntry` list.
///
/// C4's two hour figures are kept separate ([movieHours],
/// [estimatedTvHours]) rather than combined into one total: that's
/// literally what the two metric cards show, and B5's own "Your
/// Activity" card (a different, simpler summary — see
/// `your_activity_card.dart`) already covers the single-combined-number
/// case.
class LibraryStats {
  const LibraryStats({
    required this.moviesWatched,
    required this.tvShowsWatched,
    required this.movieHours,
    required this.estimatedTvHours,
    required this.averageRating,
    required this.topGenres,
    required this.mostWatchedYear,
    required this.monthlyActivity,
    this.genreTotal = 0,
    this.recentlyWatched = const [],
    this.weeklyStreak = 0,
    this.favoritesCount = 0,
    this.watchLaterCount = 0,
    this.viewerLabel,
  }) : assert(
         monthlyActivity.length == 12,
         'monthlyActivity must have exactly 12 values',
       );

  final int moviesWatched;
  final int tvShowsWatched;

  /// "Hours of movies" — watched movies' `runtimeMinutes` summed, /60. A
  /// movie with no known runtime contributes 0, not an error.
  final double movieHours;

  /// "Estimated TV hours" — watched TV shows' `episodeCount *
  /// (episodeRuntimeMinutes ?? 45)` summed, /60. The 45-min/episode
  /// fallback matches `TvShowDetail.estimatedHours`' own convention for
  /// an "estimated" figure; a show with no `episodeCount` at all (never
  /// populated, e.g. watched before that field existed) still
  /// contributes 0 regardless of the fallback, since the product is
  /// zeroed by the missing count, not the missing runtime.
  final double estimatedTvHours;

  /// "Your average rating". `null` when no watched entry has a rating —
  /// distinct from `0`, which would misleadingly read as "rated zero
  /// stars".
  final double? averageRating;

  /// "Genres you watch most" — up to 5, most-watched first, counting
  /// each watched entry's `UserMediaEntry.genres` once per genre it
  /// lists. An entry saved before that field existed has `genres: []`
  /// and simply doesn't contribute — an undercount for old data, not an
  /// error. See `library_stats_calculator.dart`'s `topGenres()` for the
  /// ranking/tie-break rule.
  final List<(Genre, int)> topGenres;

  /// The watch-date year with the most entries watched. `null` when
  /// there are no watched entries at all. Ties broken by the more
  /// recent year — see `library_stats_calculator.dart`.
  final int? mostWatchedYear;

  /// "Activity over the last 12 months" — exactly 12 values, oldest
  /// first, ending at the current month; each is a count of entries
  /// watched in that month.
  final List<int> monthlyActivity;

  /// Every genre tag counted (a title with 3 genres adds 3) — what
  /// [genreShareOf] divides by, so the shares of all genres sum to 100.
  final int genreTotal;

  /// The last watched titles, newest first (at most
  /// [recentlyWatchedLimit]) — You's "Recently watched" poster row.
  final List<UserMediaEntry> recentlyWatched;

  /// Consecutive weeks (Monday to Sunday) with something watched, ending this
  /// week — or last week, so a streak isn't lost just because this week has
  /// not had its title yet.
  final int weeklyStreak;

  /// How many titles are in Favorites / Watch later (of the type filtered).
  final int favoritesCount;
  final int watchLaterCount;

  /// What the watch history says the user is, `null` with nothing watched.
  final ViewerLabel? viewerLabel;

  static const int recentlyWatchedLimit = 6;

  int get watchedCount => moviesWatched + tvShowsWatched;

  /// Movie + estimated TV hours — the single figure You shows.
  double get totalHours => movieHours + estimatedTvHours;

  /// Titles watched this month and the month before (the last two cells of
  /// [monthlyActivity]).
  int get watchedThisMonth => monthlyActivity[11];
  int get watchedLastMonth => monthlyActivity[10];

  /// [count] as a whole percent of every genre counted (0 with none counted).
  int genreShareOf(int count) =>
      genreTotal == 0 ? 0 : (count * 100 / genreTotal).round();

  @override
  bool operator ==(Object other) =>
      other is LibraryStats &&
      other.moviesWatched == moviesWatched &&
      other.tvShowsWatched == tvShowsWatched &&
      other.movieHours == movieHours &&
      other.estimatedTvHours == estimatedTvHours &&
      other.averageRating == averageRating &&
      _listEquals(other.topGenres, topGenres) &&
      other.mostWatchedYear == mostWatchedYear &&
      _listEquals(other.monthlyActivity, monthlyActivity) &&
      other.genreTotal == genreTotal &&
      _listEquals(other.recentlyWatched, recentlyWatched) &&
      other.weeklyStreak == weeklyStreak &&
      other.favoritesCount == favoritesCount &&
      other.watchLaterCount == watchLaterCount &&
      other.viewerLabel == viewerLabel;

  @override
  int get hashCode => Object.hash(
    moviesWatched,
    tvShowsWatched,
    movieHours,
    estimatedTvHours,
    averageRating,
    Object.hashAll(topGenres),
    mostWatchedYear,
    Object.hashAll(monthlyActivity),
    genreTotal,
    Object.hashAll(recentlyWatched),
    weeklyStreak,
    favoritesCount,
    watchLaterCount,
    viewerLabel,
  );

  @override
  String toString() =>
      'LibraryStats(moviesWatched: $moviesWatched, '
      'tvShowsWatched: $tvShowsWatched, movieHours: $movieHours, '
      'estimatedTvHours: $estimatedTvHours, averageRating: $averageRating, '
      'topGenres: $topGenres, mostWatchedYear: $mostWatchedYear, '
      'monthlyActivity: $monthlyActivity, genreTotal: $genreTotal, '
      'weeklyStreak: $weeklyStreak, viewerLabel: $viewerLabel)';
}

/// Order-sensitive list content equality — [topGenres] and
/// [LibraryStats.monthlyActivity] are ranked/ordered, not sets, so this
/// (unlike `TasteProfile`'s own order-independent `_setEquals`) compares
/// position by position. A local helper for the same reason
/// `TasteProfile` has its own: no `package:collection` dependency for
/// just this (CLAUDE.md "don't add one without discussing it"), and this
/// file must stay Flutter-free too.
bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
