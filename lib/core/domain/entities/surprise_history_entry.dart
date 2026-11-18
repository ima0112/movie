import 'media_key.dart';

/// What the user did with a suggestion Surprise me showed them. The "taste
/// signal" the engine learns from: [chosen] weighs most, [saved] a little
/// less, [seen] (opened the detail) almost nothing, [discarded] (asked for
/// other 5 without picking it) a small negative.
enum SurpriseOutcome { shown, chosen, saved, seen, discarded }

/// One title shown by Surprise me, in one search session: what it was, when,
/// in which [sessionId] and what came of it. Persisted locally (drift, table
/// `surprise_history`) — never leaves the device and never feeds the user's
/// saved tastes (`docs/decisions/quiz-answers-not-saved-to-profile.md`).
///
/// Pure value — no Flutter, no storage.
class SurpriseHistoryEntry {
  const SurpriseHistoryEntry({
    required this.key,
    required this.sessionId,
    required this.shownAt,
    this.outcome = SurpriseOutcome.shown,
  });

  final MediaKey key;

  /// The Surprise-me session ("shuffle") it was shown in: every "other 5" of
  /// the same session shares it.
  final String sessionId;

  final DateTime shownAt;

  final SurpriseOutcome outcome;

  SurpriseHistoryEntry withOutcome(SurpriseOutcome outcome) =>
      SurpriseHistoryEntry(
        key: key,
        sessionId: sessionId,
        shownAt: shownAt,
        outcome: outcome,
      );

  @override
  bool operator ==(Object other) =>
      other is SurpriseHistoryEntry &&
      other.key == key &&
      other.sessionId == sessionId &&
      other.shownAt == shownAt &&
      other.outcome == outcome;

  @override
  int get hashCode => Object.hash(key, sessionId, shownAt, outcome);

  @override
  String toString() =>
      'SurpriseHistoryEntry($key, session: $sessionId, '
      'shownAt: $shownAt, $outcome)';
}
