import '../../../core/domain/entities/media_item.dart';
import 'relaxation.dart';

/// One participant's vibe-satisfaction count — `docs/DECISIONS.md`
/// section 5: "`satisfaction` allows showing 'Perfect match' (everyone at
/// 100%) or 'Best compromise: Ana 3/3, Luis 2/3'". That "3/3" wording
/// needs the raw counts, not just a percentage — [vibesRequested]/
/// [vibesMet] instead of a bare `Map<String, double>`.
class Satisfaction {
  const Satisfaction({
    required this.participantId,
    required this.vibesRequested,
    required this.vibesMet,
  }) : assert(
         vibesMet <= vibesRequested,
         'vibesMet cannot exceed vibesRequested',
       );

  final String participantId;
  final int vibesRequested;
  final int vibesMet;

  /// `0` when [vibesRequested] is `0` (nothing to satisfy — doesn't
  /// happen today since E2 always asks for exactly 3, but this stays
  /// safe if that ever changes) rather than dividing by zero.
  double get percentage => vibesRequested == 0 ? 0 : vibesMet / vibesRequested;

  /// F5's "Everyone 3/3" / "Ana 3/3" — 100% for this participant.
  bool get isPerfect => vibesRequested > 0 && vibesMet == vibesRequested;

  @override
  bool operator ==(Object other) =>
      other is Satisfaction &&
      other.participantId == participantId &&
      other.vibesRequested == vibesRequested &&
      other.vibesMet == vibesMet;

  @override
  int get hashCode => Object.hash(participantId, vibesRequested, vibesMet);

  @override
  String toString() =>
      'Satisfaction($participantId, $vibesMet/$vibesRequested)';
}

/// What the engine returns — `docs/DECISIONS.md` section 5: "Returns
/// `MatchResult { winner, alternatives[3–4], satisfaction {participant →
/// % of their vibes met}, relaxations[] }`".
class MatchResult {
  const MatchResult({
    required this.winner,
    required this.alternatives,
    required this.satisfaction,
    this.relaxationsApplied = const [],
  });

  final MediaItem winner;

  /// 3–4 runner-ups — F5's "Find another" rotates through these.
  final List<MediaItem> alternatives;

  /// One entry per participant.
  final List<Satisfaction> satisfaction;

  /// Which [Relaxation] steps this result needed, in the order they were
  /// applied — empty if the very first `MatchQuery` already had enough
  /// candidates. F5/F5b's own "the screen states what was relaxed" reads
  /// this list.
  final List<Relaxation> relaxationsApplied;

  /// F5's "Perfect match" pill (green) vs "Best compromise" (gray) —
  /// everyone at 100%.
  bool get isPerfectMatch => satisfaction.every((s) => s.isPerfect);

  @override
  bool operator ==(Object other) =>
      other is MatchResult &&
      other.winner == winner &&
      _listEquals(other.alternatives, alternatives) &&
      _listEquals(other.satisfaction, satisfaction) &&
      _listEquals(other.relaxationsApplied, relaxationsApplied);

  @override
  int get hashCode => Object.hash(
    winner,
    Object.hashAll(alternatives),
    Object.hashAll(satisfaction),
    Object.hashAll(relaxationsApplied),
  );

  @override
  String toString() =>
      'MatchResult(winner: $winner, alternatives: $alternatives, '
      'satisfaction: $satisfaction, relaxationsApplied: $relaxationsApplied)';
}

/// Order-sensitive list content equality — same local stand-in used
/// throughout this codebase (e.g. `UserMediaEntry`) for
/// `package:collection`'s `ListEquality`.
bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
