import '../entities/surprise_history_entry.dart';
import '../entities/surprise_session.dart';

/// The two numbers B5's stats card shows for Surprise me, over all time:
/// how many sessions were run and how many cards were chosen in them.
/// Pure — no Flutter, no storage.
class SurpriseSummary {
  const SurpriseSummary({required this.sessions, required this.picks});

  /// Sessions run (one per time the user started Surprise me and was shown a
  /// first batch), chosen anything or not.
  final int sessions;

  /// Cards chosen (`SurpriseOutcome.chosen`) across every session.
  final int picks;

  /// Surprise me has been used at least once.
  bool get hasActivity => sessions > 0;

  @override
  bool operator ==(Object other) =>
      other is SurpriseSummary &&
      other.sessions == sessions &&
      other.picks == picks;

  @override
  int get hashCode => Object.hash(sessions, picks);
}

/// [SurpriseSummary] from the recorded [sessions] and what they showed
/// ([history]).
SurpriseSummary calculateSurpriseSummary({
  required List<SurpriseSession> sessions,
  required List<SurpriseHistoryEntry> history,
}) => SurpriseSummary(
  sessions: sessions.length,
  picks: history.where((e) => e.outcome == SurpriseOutcome.chosen).length,
);
