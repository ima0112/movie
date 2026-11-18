import 'dart:math';

import '../../../core/domain/entities/genre.dart';
import '../../../core/domain/entities/surprise_history_entry.dart';

/// What the Surprise-me history says about the user's taste, as a genre
/// affinity the engine adds to the one it already has (My List, the profile)
/// — `docs/DECISIONS.md` §5.
///
/// Each shown card with an outcome that means something adds that outcome's
/// weight to every one of its genres, scaled down by how long ago it was:
/// [chosen] strong, [saved] medium, [revisited] weak. `viewed` (only shown) and
/// `rerolled` ("other 5" was asked) weigh **nothing** — the second is a fact
/// kept for later, not a verdict, because the user's own answers shaped that
/// batch. Passing a card is never recorded, so it can't count against a genre.
///
/// Pure function of the entries and the clock.
abstract final class SurpriseHistoryAffinity {
  static const Map<SurpriseOutcome, double> weights = {
    SurpriseOutcome.chosen: 6,
    SurpriseOutcome.saved: 4,
    SurpriseOutcome.revisited: 2,
    SurpriseOutcome.viewed: 0,
    SurpriseOutcome.rerolled: 0,
  };

  /// A pick loses half its weight every this many days.
  static const double halfLifeDays = 45;

  /// Entries older than this are ignored.
  static const Duration maxAge = Duration(days: 180);

  /// No genre gets more than this from the history alone, so a run of picks in
  /// one genre can't take the whole batch over.
  static const int maxPerGenre = 8;

  static Map<Genre, int> from(
    Iterable<SurpriseHistoryEntry> entries, {
    required DateTime now,
  }) {
    final sums = <Genre, double>{};
    for (final entry in entries) {
      final weight = weights[entry.outcome] ?? 0;
      if (weight == 0) continue;
      final age = now.difference(entry.shownAt);
      if (age > maxAge) continue;
      final decay = pow(0.5, age.inHours / 24 / halfLifeDays).toDouble();
      for (final genre in entry.genres) {
        sums[genre] = (sums[genre] ?? 0) + weight * decay;
      }
    }
    return {
      for (final e in sums.entries)
        if (e.value.round() != 0) e.key: min(e.value.round(), maxPerGenre),
    };
  }
}
