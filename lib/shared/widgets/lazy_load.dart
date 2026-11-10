import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Runs [onNear] when its [child] is about to come into view in the nearest
/// scrollable — the app's one mechanism for **loading on demand**: a block of
/// a long page (a carousel, a section, a row) starts fetching its data only
/// once the user is scrolling toward it, instead of every block fetching at
/// once when the page opens.
///
/// "Near" means within [distance] logical pixels of the visible area along
/// the scroll axis (before it or after it). It works in any scroll view —
/// lazy lists, a `Column` in a `SingleChildScrollView`, slivers — because it
/// measures the child's position against the scroll position, rather than
/// relying on when the list happens to build it. With no scrollable around,
/// it fires at once.
///
/// [onNear] runs **once per [loadKey]**: when the key changes (the filters a
/// section depends on, say) the next time the child is near it runs again,
/// immediately if it already is. While waiting it checks after each frame, so
/// content above growing or shrinking can bring it near without a scroll.
/// [onNear] should be idempotent anyway.
///
/// Pure presentation, no feature dependency; the data work is the callback's.
class LazyLoad extends StatefulWidget {
  const LazyLoad({
    super.key,
    required this.onNear,
    required this.child,
    this.loadKey,
    this.distance = defaultDistance,
  });

  /// Called when the child becomes near (once per [loadKey]).
  final VoidCallback onNear;

  /// A new value re-arms [onNear].
  final Object? loadKey;

  /// How far outside the visible area still counts as near.
  final double distance;

  final Widget child;

  /// About one screen of lead — enough for a typical fetch to finish before
  /// the user gets there.
  static const double defaultDistance = 400;

  @override
  State<LazyLoad> createState() => _LazyLoadState();
}

class _LazyLoadState extends State<LazyLoad> {
  ScrollPosition? _position;
  bool _fired = false;
  bool _polling = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final position = Scrollable.maybeOf(context)?.position;
    if (position != _position) {
      _position?.removeListener(_check);
      _position = position;
      _position?.addListener(_check);
    }
    _arm();
  }

  @override
  void didUpdateWidget(covariant LazyLoad oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.loadKey != oldWidget.loadKey) {
      _fired = false;
      _arm();
    }
  }

  @override
  void dispose() {
    _position?.removeListener(_check);
    super.dispose();
  }

  /// Starts watching if there is still something to fire.
  void _arm() {
    if (_fired || _polling) return;
    _polling = true;
    WidgetsBinding.instance.addPostFrameCallback(_poll);
  }

  void _poll(Duration _) {
    _polling = false;
    if (!mounted || _fired) return;
    _check();
    if (!_fired) _arm();
  }

  void _check() {
    if (!mounted || _fired) return;
    if (_isNear()) {
      _fired = true;
      widget.onNear();
    }
  }

  bool _isNear() {
    final position = _position;
    // Nothing scrolls around it: nothing to wait for.
    if (position == null) return true;
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return false;
    final viewport = RenderAbstractViewport.maybeOf(box);
    if (viewport == null) return true;

    // The scroll offset at which the child's leading edge meets the
    // viewport's, and how long it is along the scroll axis.
    final start = viewport.getOffsetToReveal(box, 0).offset;
    final extent = axisDirectionIsReversed(position.axisDirection)
        ? 0.0
        : _extentAlong(position.axis, box.size);
    final visibleStart = position.pixels;
    final visibleEnd = position.pixels + position.viewportDimension;
    return start <= visibleEnd + widget.distance &&
        start + extent >= visibleStart - widget.distance;
  }

  static double _extentAlong(Axis axis, Size size) =>
      axis == Axis.vertical ? size.height : size.width;

  @override
  Widget build(BuildContext context) => widget.child;
}
