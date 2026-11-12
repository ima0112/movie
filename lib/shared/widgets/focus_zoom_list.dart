import 'package:flutter/material.dart';

/// A horizontal list of fixed-width items where the one at the leading edge
/// is at full size and the rest shrink and dim a little the farther they sit
/// from it — a "focus" that moves as the list scrolls (B2's "Top today").
///
/// Items are [itemExtent] wide including their leading gap; they are scaled
/// from the bottom so their bases stay aligned. With reduced motion
/// (`MediaQuery.disableAnimations`) it is a plain list.
class FocusZoomList extends StatefulWidget {
  const FocusZoomList({
    super.key,
    required this.itemCount,
    required this.itemExtent,
    required this.itemBuilder,
  });

  final int itemCount;

  /// Distance between the leading edges of two neighbouring items.
  final double itemExtent;
  final IndexedWidgetBuilder itemBuilder;

  /// Scale and opacity of an item far from the focus.
  static const double minScale = 0.86;
  static const double minOpacity = 0.7;

  /// How many items away the minimum is reached.
  static const double _reach = 1.5;

  /// The `(scale, opacity)` of item [index] with the list scrolled to
  /// [offset].
  static (double, double) factorsFor({
    required int index,
    required double itemExtent,
    required double offset,
  }) {
    final distance =
        ((index * itemExtent - offset).abs() / itemExtent) / _reach;
    final t = distance.clamp(0.0, 1.0);
    return (1 + (minScale - 1) * t, 1 + (minOpacity - 1) * t);
  }

  @override
  State<FocusZoomList> createState() => _FocusZoomListState();
}

class _FocusZoomListState extends State<FocusZoomList> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    return ListView.builder(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        final child = widget.itemBuilder(context, index);
        if (still) return child;
        return AnimatedBuilder(
          animation: _controller,
          child: child,
          builder: (context, child) {
            final offset = _controller.hasClients ? _controller.offset : 0.0;
            final (scale, opacity) = FocusZoomList.factorsFor(
              index: index,
              itemExtent: widget.itemExtent,
              offset: offset,
            );
            return Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                alignment: Alignment.bottomCenter,
                child: child,
              ),
            );
          },
        );
      },
    );
  }
}
