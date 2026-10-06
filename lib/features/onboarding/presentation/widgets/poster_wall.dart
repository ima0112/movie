import 'package:flutter/material.dart';

import 'poster_wall_column.dart';

/// Step 0's background — `docs/SCREENS.md` A2: "poster wall (4 staggered
/// columns, 55% opacity, slow vertical drift; static with 'reduce
/// motion')... Offline: same wall with placeholders."
///
/// Pure presentation (CLAUDE.md rule 9): takes already-resolved poster
/// URLs — fetching `/trending/all/week` is the eventual screen's job.
/// Empty [posterUrls] renders every tile as a placeholder block.
class PosterWall extends StatefulWidget {
  const PosterWall({super.key, this.posterUrls = const []});

  final List<String?> posterUrls;

  static const int _columnCount = 4;

  @override
  State<PosterWall> createState() => _PosterWallState();
}

class _PosterWallState extends State<PosterWall>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const double _opacity = 0.55;
  static const double _tileHeight = 160;
  static const Duration _driftDuration = Duration(seconds: 24);

  // A different phase (0, ¼, ½, ¾) and top offset per column is what
  // makes identically-animated columns read as "staggered".
  static const List<double> _columnPhase = [0, 0.25, 0.5, 0.75];
  static const List<double> _columnTopOffset = [0, 60, 110, 30];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _driftDuration);
    // MediaQuery isn't available yet in initState — didChangeDependencies
    // (always called once right before the first build) does the initial
    // sync too, so nothing is skipped.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  void _syncAnimation() {
    if (MediaQuery.of(context).disableAnimations) {
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
    final columns = _distribute(widget.posterUrls, PosterWall._columnCount);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Opacity(
      opacity: _opacity,
      child: Row(
        children: [
          for (var i = 0; i < columns.length; i++)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: _columnTopOffset[i]),
                child: ClipRect(
                  // The column is naturally taller than its given space
                  // (enough tiles for a full drift cycle); OverflowBox
                  // lets it lay out at full height, ClipRect paints it.
                  child: OverflowBox(
                    alignment: Alignment.topCenter,
                    maxHeight: double.infinity,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        final drift = reduceMotion
                            ? 0.0
                            : ((_controller.value + _columnPhase[i]) % 1.0) *
                                  _tileHeight;
                        return Transform.translate(
                          offset: Offset(0, -drift),
                          child: child,
                        );
                      },
                      child: PosterWallColumn(urls: columns[i]),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Round-robins posters into [columnCount] lists, each repeated enough
  // to cover one drift cycle with no gap showing through the ClipRect.
  static List<List<String?>> _distribute(List<String?> urls, int columnCount) {
    final source = urls.isEmpty
        ? List<String?>.filled(columnCount * 3, null)
        : urls;
    final columns = List.generate(columnCount, (_) => <String?>[]);
    for (var i = 0; i < source.length * 2; i++) {
      columns[i % columnCount].add(source[i % source.length]);
    }
    return columns;
  }
}
