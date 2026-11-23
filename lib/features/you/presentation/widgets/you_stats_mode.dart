import '../../../../core/domain/stats/library_stats.dart';
import '../../../../core/domain/stats/surprise_summary.dart';

/// What B5's stats card shows, from what is known about its two sources.
enum YouStatsMode {
  /// Nothing to show — or not known yet: the card isn't drawn at all (and
  /// takes no space), so it never flashes in and out.
  hidden,

  /// There is activity, but the other source hasn't answered yet: a skeleton.
  loading,

  /// Something has been watched, no Surprise me session yet.
  library,

  /// Surprise me has been used, nothing has been watched.
  surprise,

  /// Both: the library's numbers and Surprise me's summary.
  both,
}

/// The stats card's mode: it exists when something has been **watched** or
/// Surprise me has run a **session** — the two places C4's numbers come from
/// (a title only saved to Favorites or Watch later is not enough: C4 would have
/// nothing to show). `null` means "not read yet".
YouStatsMode youStatsMode({
  required LibraryStats? library,
  required SurpriseSummary? surprise,
}) {
  final hasLibrary = library != null && library.watchedCount > 0;
  final hasSurprise = surprise != null && surprise.hasActivity;
  if (hasLibrary && hasSurprise) return YouStatsMode.both;
  if (hasLibrary) {
    return surprise == null ? YouStatsMode.loading : YouStatsMode.library;
  }
  if (hasSurprise) {
    return library == null ? YouStatsMode.loading : YouStatsMode.surprise;
  }
  return YouStatsMode.hidden;
}
