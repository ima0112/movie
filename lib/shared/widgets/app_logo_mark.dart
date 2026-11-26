import 'package:flutter/widgets.dart';

import 'logo_mark_painter.dart';

/// PickMe's mark: an amber card with sparkles over a fan of two cards
/// (`docs/DESIGN_SYSTEM.md`, "Logo"). Drawn in code ([LogoMarkPainter]), so it is
/// sharp at any [size], paints in the first frame (it is the splash's logo, no
/// image to decode) and takes its colours from `AppColors`.
///
/// [size] is the side of the design's square, in which the artwork fills about
/// two thirds. Decorative: it is hidden from screen readers.
class AppLogoMark extends StatelessWidget {
  const AppLogoMark({super.key, this.size = defaultSize});

  final double size;

  /// The size at which its artwork measures what the native splash's does (about
  /// 80 dp wide: that image is 128 dp with the mark filling ~62% of it, this box
  /// ~73%), so the in-app splash draws it where, and as big as, the native one
  /// left it.
  static const double defaultSize = 110;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: const CustomPaint(painter: LogoMarkPainter()),
      ),
    );
  }
}
