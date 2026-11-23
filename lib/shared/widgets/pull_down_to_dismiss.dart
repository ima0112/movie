import 'package:flutter/material.dart';

/// Closes a bottom sheet whose content scrolls when the list is pulled down
/// past its top: a modal sheet's own drag never sees a swipe that starts on a
/// list, because the list takes it, so this watches the list's scroll
/// notifications instead and calls [onDismiss] when the pull is deliberate —
/// longer than [distance] px, or a fast flick ([velocity] px/s) at the top.
///
/// Only the vertical list directly under it counts (a horizontal row inside
/// the content is ignored).
class PullDownToDismiss extends StatefulWidget {
  const PullDownToDismiss({
    super.key,
    required this.onDismiss,
    required this.child,
  });

  final VoidCallback onDismiss;
  final Widget child;

  /// How far past the top the list must be pulled.
  static const double distance = 72;

  /// How fast a flick down at the top must be.
  static const double velocity = 700;

  @override
  State<PullDownToDismiss> createState() => _PullDownToDismissState();
}

class _PullDownToDismissState extends State<PullDownToDismiss> {
  double _pulled = 0;

  bool _counts(ScrollNotification n) =>
      n.depth == 0 && n.metrics.axis == Axis.vertical;

  bool _onScroll(ScrollNotification n) {
    if (!_counts(n)) return false;
    switch (n) {
      case ScrollStartNotification():
        _pulled = 0;
      case OverscrollNotification(:final overscroll) when overscroll < 0:
        // Clamping physics (Android): the extra pull arrives as overscroll.
        _pulled += -overscroll;
      case ScrollUpdateNotification(:final metrics)
          when metrics.pixels < metrics.minScrollExtent:
        // Bouncing physics (iOS): the list itself moves past its top.
        final past = metrics.minScrollExtent - metrics.pixels;
        if (past > _pulled) _pulled = past;
      case ScrollEndNotification(:final metrics, :final dragDetails):
        final atTop = metrics.pixels <= metrics.minScrollExtent;
        final flicked =
            atTop &&
            dragDetails != null &&
            dragDetails.velocity.pixelsPerSecond.dy >
                PullDownToDismiss.velocity;
        final pulledFar = _pulled > PullDownToDismiss.distance;
        _pulled = 0;
        if (flicked || pulledFar) widget.onDismiss();
      default:
    }
    return false;
  }

  @override
  Widget build(BuildContext context) =>
      NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: widget.child,
      );
}
