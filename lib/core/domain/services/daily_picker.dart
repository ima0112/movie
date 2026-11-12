/// A deterministic, day-stable rotation — the heart of B1's "For you" /
/// "Because you…" variety.
///
/// Candidates are served in *cycles*: each cycle is a shuffled order of every
/// candidate (a candidate with weight *w* appears *w* times), one per day, so
/// everything comes up before anything repeats, heavier candidates more often,
/// and the same candidate never shows two days running when there is any
/// alternative (also across the end of one cycle and the start of the next).
/// The shuffle depends only on the cycle number and the slot's [salt], so the
/// same day always gives the same pick — opening or refreshing the page never
/// reshuffles — and a new day gives the next one. There is **nothing to
/// persist**: the whole sequence is recomputed from the date, and when the
/// candidates change (new tastes, a new favorite), the rotation simply follows.
///
/// Pure domain: no Flutter, no clock (the caller passes [today]), no random
/// source — a small hash drives the shuffle, identical on every platform.
class DailyPicker {
  const DailyPicker(this.today);

  /// The day the picks are for; only its date matters.
  final DateTime today;

  /// Today's pick among [candidates] (each with a weight ≥ 1; their order must
  /// be deterministic — callers sort them), for the slot named by [salt] (so
  /// two slots don't mirror each other). `null` with no candidates.
  T? pick<T>(List<(T, int)> candidates, {required String salt}) {
    if (candidates.isEmpty) return null;
    final slots = <T>[
      for (final c in candidates)
        for (var i = 0; i < c.$2.clamp(1, 1000); i++) c.$1,
    ];
    final length = slots.length;
    final day = _epochDay(today);
    // Two different options simply alternate (a cycle boundary can't be
    // fixed locally with so few).
    if (length == 2 && slots[0] != slots[1]) {
      final flip = _unit('flip|$salt') < 0.5 ? 0 : 1;
      return slots[(day + flip) % 2];
    }
    final cycle = day ~/ length;
    return _sequence(slots, cycle, salt)[day % length];
  }

  /// [items] in an order that is the same all day and different tomorrow —
  /// for lists that would otherwise show the same first entries forever. The
  /// order depends only on the date and [salt], never on the clock's time.
  List<T> shuffled<T>(List<T> items, {required String salt}) =>
      _shuffled(items, _epochDay(today), salt);

  /// Up to [count] distinct picks, each one drawn from what is left.
  List<T> pickMany<T>(
    List<(T, int)> candidates, {
    required int count,
    required String salt,
  }) {
    final left = [...candidates];
    final picked = <T>[];
    while (picked.length < count && left.isNotEmpty) {
      final next = pick(left, salt: '$salt#${picked.length}');
      if (next == null) break;
      picked.add(next);
      left.removeWhere((c) => c.$1 == next);
    }
    return picked;
  }

  /// The order of one cycle: its inner order, with its start kept different
  /// from the previous cycle's end.
  List<T> _sequence<T>(List<T> slots, int cycle, String salt) {
    final seq = _inner(slots, cycle, salt);
    final length = seq.length;
    if (length < 3) return seq;
    // The boundary fix below only touches indexes 0..length-2, so the last
    // element of a cycle is always its inner one — the previous cycle's end
    // can be known without computing that cycle's own boundary.
    final previousLast = _inner(slots, cycle - 1, salt).last;
    if (seq.first != previousLast) return seq;
    for (var j = 1; j < length - 1; j++) {
      final candidate = seq[j];
      if (candidate == previousLast) continue;
      final moved = seq.first;
      // The swap must not create an equal pair around index j.
      if (moved != seq[j - 1] && moved != seq[j + 1]) {
        seq[0] = candidate;
        seq[j] = moved;
        break;
      }
    }
    return seq;
  }

  /// One cycle's shuffled order with equal neighbours spread apart.
  List<T> _inner<T>(List<T> slots, int cycle, String salt) {
    final seq = _shuffled(slots, cycle, salt);
    for (var i = 1; i < seq.length; i++) {
      if (seq[i] != seq[i - 1]) continue;
      for (var j = i + 1; j < seq.length; j++) {
        if (seq[j] != seq[i]) {
          final t = seq[i];
          seq[i] = seq[j];
          seq[j] = t;
          break;
        }
      }
    }
    return seq;
  }

  /// [slots] in a hash-driven order that depends on [cycle] and [salt].
  List<T> _shuffled<T>(List<T> slots, int cycle, String salt) {
    final keyed =
        [for (var i = 0; i < slots.length; i++) (_unit('$cycle|$salt|$i'), i)]
          ..sort(
            (a, b) => a.$1.compareTo(b.$1) != 0
                ? a.$1.compareTo(b.$1)
                : a.$2.compareTo(b.$2),
          );
    return [for (final k in keyed) slots[k.$2]];
  }

  /// Whole days since a fixed date; DST-proof (UTC).
  static int _epochDay(DateTime d) => DateTime.utc(
    d.year,
    d.month,
    d.day,
  ).difference(DateTime.utc(2020)).inDays;

  /// A number in [0, 1) that depends only on [key] (FNV-1a, then a final mix
  /// so near-identical inputs spread out).
  static double _unit(String key) {
    var h = 0x811c9dc5;
    for (final unit in key.codeUnits) {
      h = ((h ^ unit) * 0x01000193) & 0xffffffff;
    }
    h ^= h >> 16;
    h = (h * 0x85ebca6b) & 0xffffffff;
    h ^= h >> 13;
    h = (h * 0xc2b2ae35) & 0xffffffff;
    h ^= h >> 16;
    return h / 0x100000000;
  }
}
