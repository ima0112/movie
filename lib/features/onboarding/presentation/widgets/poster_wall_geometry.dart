/// `PosterWallColumn`'s own drift math, pure and Flutter-free so it can
/// be unit-tested directly (`poster_wall_geometry_test.dart`) instead of
/// only ever being exercised indirectly through a widget test — this is
/// exactly the kind of bug (a previous version's static top `Padding`
/// shrinking a column's own clip height) a widget test alone didn't
/// catch, since the RenderBox size assertion it used doesn't see what's
/// actually *painted* inside that box.
library;

/// How many consecutive copies of a column's own poster set are
/// rendered back to back — see [driftOffset]'s own doc comment for why
/// 3 is the minimum that keeps the loop gap-free at every point in the
/// cycle, not just most of it.
const int posterWallCopies = 3;

/// The column's own `Transform.translate` offset (its `dy`) for a given
/// moment [t] (0–1, one full `AnimationController` lap) and [startPhase]
/// (0–1, this column's own stagger). [goesUp] picks the drift direction
/// by reversing the phase fed into the same formula, rather than a
/// mirrored copy layout: at [t] = 0, [goesUp] true or false both start
/// from [startPhase] itself (so "reduce motion" — which forces `t: 0` —
/// shows exactly the configured [startPhase] position).
///
/// The `- loopHeight` term keeps the covered range inside
/// `[loopHeight, 2 * loopHeight + viewportHeight]` — see
/// [visibleTileRange] — comfortably inside the `posterWallCopies * 3`
/// copies actually rendered, so the visible window never touches
/// either edge of the rendered content.
double driftOffset({
  required double startPhase,
  required double t,
  required bool goesUp,
  required double loopHeight,
}) {
  final rawPhase = (startPhase + t) % 1.0;
  final phase = goesUp ? rawPhase : 1.0 - rawPhase;
  return -phase * loopHeight - loopHeight;
}

/// What a column's own [offset] (from [driftOffset]) makes visible: the
/// flat tile-slot indices (0-based, spanning all [posterWallCopies]
/// copies — index `i` occupies content-local Y
/// `[i * tileHeight, (i + 1) * tileHeight)`) touching the top and
/// bottom edge of a [viewportHeight]-tall viewport, and whether the
/// *rendered* content (`posterWallCopies * loopHeight` tall, starting
/// at content-local Y 0) actually covers that whole viewport with no
/// gap at either edge — the property a previous bug violated (a static
/// `Padding` shrank the rendered block below the viewport's own
/// height), and the one [coversViewport] exists to catch directly.
class VisibleTileRange {
  const VisibleTileRange({
    required this.firstIndex,
    required this.lastIndex,
    required this.coversViewport,
  });

  final int firstIndex;
  final int lastIndex;
  final bool coversViewport;

  @override
  bool operator ==(Object other) =>
      other is VisibleTileRange &&
      other.firstIndex == firstIndex &&
      other.lastIndex == lastIndex &&
      other.coversViewport == coversViewport;

  @override
  int get hashCode => Object.hash(firstIndex, lastIndex, coversViewport);

  @override
  String toString() =>
      'VisibleTileRange(first: $firstIndex, last: $lastIndex, '
      'covers: $coversViewport)';
}

VisibleTileRange visibleTileRange({
  required double offset,
  required double loopHeight,
  required double viewportHeight,
  required double tileHeight,
  int copies = posterWallCopies,
}) {
  final contentTop = -offset;
  final contentBottom = contentTop + viewportHeight;
  final renderedHeight = copies * loopHeight;

  return VisibleTileRange(
    firstIndex: (contentTop / tileHeight).floor(),
    lastIndex: ((contentBottom - 1) / tileHeight).floor(),
    coversViewport: contentTop >= 0 && contentBottom <= renderedHeight,
  );
}

/// How long one full lap (0→1) of a column's own `AnimationController`
/// takes to drift [loopHeight] logical pixels at [speed] logical
/// pixels/second. Microsecond precision, not milliseconds — a slow
/// [speed] shouldn't round the *period itself* into a coarser step than
/// necessary; [driftOffset]'s own continuous double math is what keeps
/// the motion smooth frame to frame, this just avoids adding a second,
/// separate source of imprecision on top of it.
Duration driftDuration({required double loopHeight, required double speed}) {
  final seconds = loopHeight / speed;
  return Duration(
    microseconds: (seconds * Duration.microsecondsPerSecond).round(),
  );
}

/// Per-column drift speed, logical pixels/second — `docs/SCREENS.md`
/// A2's own "slow vertical drift" turned into an actual number, slow
/// enough that the wall reads as "almost still" at a glance and only
/// noticeably moved after watching it for a few seconds. A slight
/// per-column variation — not one shared speed — reads as a subtle
/// depth effect rather than 4 columns moving in lockstep.
/// [minAllowedSpeed]/[maxAllowedSpeed] exist so a future edit can't push
/// a column's speed out of the intended "slow" range without a test
/// actually catching it (`poster_wall_geometry_test.dart`).
abstract final class PosterWallConfig {
  const PosterWallConfig._();

  static const List<double> columnSpeeds = [4, 4, 4, 4];
  static const double minAllowedSpeed = 4;
  static const double maxAllowedSpeed = 10;
}
