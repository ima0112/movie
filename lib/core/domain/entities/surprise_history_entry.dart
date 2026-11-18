import 'genre.dart';
import 'media_key.dart';

/// What the user did with a card Surprise me showed them — the taste signal the
/// engine learns from (`docs/DECISIONS.md` §5). In order of strength:
/// [chosen] (double tap / "Choose this") strong, [saved] (to Watch later) medium,
/// [revisited] (seen again, its detail opened or lingered on) weakly positive,
/// [viewed] (only shown) neutral, and [rerolled] — "other 5" was asked and the
/// batch had nothing saved or chosen — recorded as a **fact**, not a verdict:
/// it carries no weight until real data shows it means something. Passing a
/// card is never recorded as a rejection.
enum SurpriseOutcome {
  viewed,
  rerolled,
  revisited,
  saved,
  chosen;

  /// A later outcome never replaces a stronger one (a saved card that is
  /// looked at again stays saved).
  bool get isPick => this == saved || this == chosen;

  /// Whether `this` may replace [current] in the history.
  bool canReplace(SurpriseOutcome current) => index > current.index;
}

/// One card shown by Surprise me, in one search session and one batch of it:
/// what it was, its genres (so the engine can learn from it), when, and what
/// came of it. Persisted locally (drift, table `surprise_history`) — never
/// leaves the device and never feeds the user's saved tastes
/// (`docs/decisions/quiz-answers-not-saved-to-profile.md`).
///
/// Pure value — no Flutter, no storage.
class SurpriseHistoryEntry {
  const SurpriseHistoryEntry({
    required this.key,
    required this.sessionId,
    required this.shownAt,
    this.batch = 1,
    this.genres = const [],
    this.outcome = SurpriseOutcome.viewed,
  });

  final MediaKey key;

  /// The Surprise-me session ("shuffle") it was shown in: every "other 5" of the
  /// same session shares it.
  final String sessionId;

  final DateTime shownAt;

  /// Which batch of the session (1 = the first five, 2 = after one "other 5"…).
  final int batch;

  /// The title's genres when it was shown.
  final List<Genre> genres;

  final SurpriseOutcome outcome;

  SurpriseHistoryEntry withOutcome(SurpriseOutcome outcome) =>
      SurpriseHistoryEntry(
        key: key,
        sessionId: sessionId,
        shownAt: shownAt,
        batch: batch,
        genres: genres,
        outcome: outcome,
      );

  @override
  bool operator ==(Object other) =>
      other is SurpriseHistoryEntry &&
      other.key == key &&
      other.sessionId == sessionId &&
      other.shownAt == shownAt &&
      other.batch == batch &&
      _listEquals(other.genres, genres) &&
      other.outcome == outcome;

  @override
  int get hashCode => Object.hash(
    key,
    sessionId,
    shownAt,
    batch,
    Object.hashAll(genres),
    outcome,
  );

  @override
  String toString() =>
      'SurpriseHistoryEntry($key, session: $sessionId, batch: $batch, '
      'shownAt: $shownAt, genres: $genres, $outcome)';
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
