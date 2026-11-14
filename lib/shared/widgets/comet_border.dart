import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// A comet-like glint of [color] that runs round the border of [child] — a
/// bright head with a fading tail, and a soft blurred glow behind it that moves
/// with it — once every [lap], forever. It is drawn over the child's own edge
/// (a rounded rectangle of [radius]) and never takes a touch.
///
/// With the system's "reduce motion" on it stands still: the same comet frozen
/// at [stillProgress], no ticker running at all.
///
/// Only the painter repaints as it runs (a `RepaintBoundary` keeps the child
/// out of it).
class CometBorder extends StatefulWidget {
  const CometBorder({
    super.key,
    required this.radius,
    required this.child,
    this.color = AppColors.accent,
    this.lap = const Duration(seconds: 5),
  });

  final double radius;
  final Widget child;
  final Color color;

  /// How long one full turn of the border takes.
  final Duration lap;

  /// Where the frozen comet sits on its lap (0 = top-left, clockwise): on the
  /// top edge, near the left corner — the card's lit corner.
  static const double stillProgress = 0.08;

  @override
  State<CometBorder> createState() => _CometBorderState();
}

class _CometBorderState extends State<CometBorder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.lap,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => CustomPaint(
                  painter: CometBorderPainter(
                    progress: still
                        ? CometBorder.stillProgress
                        : _controller.value,
                    radius: widget.radius,
                    color: widget.color,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Paints the comet at [progress] (0..1 of the border's length, clockwise from
/// the top-left corner's end).
class CometBorderPainter extends CustomPainter {
  const CometBorderPainter({
    required this.progress,
    required this.radius,
    required this.color,
  });

  final double progress;
  final double radius;
  final Color color;

  /// The tail's length over the border's.
  static const double tail = 0.22;

  /// How many segments the fading tail is drawn in.
  static const int _segments = 24;

  static const double _stroke = 2;
  static const double _glowStroke = 7;
  static const double _glowBlur = 8;
  static const double _glowOpacity = 0.45;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final path = _perimeter(size);
    final metric = path.computeMetrics().first;
    final length = metric.length;
    final head = progress * length;
    final tailLength = tail * length;

    // The blurred glow, behind the comet and moving with it: the head half of
    // the tail, wide and soft.
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = _glowStroke
      ..color = color.withValues(alpha: _glowOpacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, _glowBlur);
    canvas.drawPath(_slice(metric, head - tailLength / 2, head), glow);

    // The comet: the tail as short segments, each fainter than the last,
    // ending in the bright head.
    final segment = tailLength / _segments;
    for (var i = 0; i < _segments; i++) {
      final end = head - i * segment;
      final fade = math.pow(1 - i / _segments, 1.8).toDouble();
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = _stroke
        ..color = color.withValues(alpha: fade);
      canvas.drawPath(_slice(metric, end - segment, end), paint);
    }
  }

  /// The part of [metric] between [from] and [to] (distances along it), which
  /// may run past either end of the loop.
  static Path _slice(ui.PathMetric metric, double from, double to) {
    final length = metric.length;
    var start = from % length;
    var end = to % length;
    if (start < 0) start += length;
    if (end < 0) end += length;
    if (start <= end) return metric.extractPath(start, end);
    return metric.extractPath(start, length)
      ..addPath(metric.extractPath(0, end), Offset.zero);
  }

  /// The border as one clockwise path that starts where the top-left corner
  /// ends, inset by half the stroke so it lies on the card's edge.
  Path _perimeter(Size size) {
    final inset = _stroke / 2;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - 2 * inset,
      size.height - 2 * inset,
    );
    final r = math.min(radius - inset, math.min(rect.width, rect.height) / 2);
    return Path()
      ..moveTo(rect.left + r, rect.top)
      ..lineTo(rect.right - r, rect.top)
      ..arcToPoint(Offset(rect.right, rect.top + r), radius: Radius.circular(r))
      ..lineTo(rect.right, rect.bottom - r)
      ..arcToPoint(
        Offset(rect.right - r, rect.bottom),
        radius: Radius.circular(r),
      )
      ..lineTo(rect.left + r, rect.bottom)
      ..arcToPoint(
        Offset(rect.left, rect.bottom - r),
        radius: Radius.circular(r),
      )
      ..lineTo(rect.left, rect.top + r)
      ..arcToPoint(Offset(rect.left + r, rect.top), radius: Radius.circular(r))
      ..close();
  }

  @override
  bool shouldRepaint(CometBorderPainter old) =>
      old.progress != progress || old.radius != radius || old.color != color;
}
