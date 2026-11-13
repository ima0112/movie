import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

/// How much of the illustration fits the card: all of it, a smaller stack, or
/// none (see [TasteCardPosters]).
enum TasteCardPostersMode { full, compact, none }

/// The taste card's illustration: real posters stacked with different tilts,
/// hinting at the recommendations the card promises. Static, bundled images
/// (`assets/illustrations/taste_card/`: *Breaking Bad*, *Stranger Things* and
/// *Spider-Man: Into the Spider-Verse*, one green, one red, one blue) — they
/// never change and need no network. Decorative: hidden from screen readers.
///
/// Two sizes: the full stack of three, and a [compact] one — two smaller
/// posters — for a card too narrow to leave its text [minTextWidth]. The
/// posters bleed a little past the stack's own width ([_bleed]) into the
/// card's padding, which is what keeps the stack slim.
class TasteCardPosters extends StatelessWidget {
  const TasteCardPosters({super.key, this.compact = false});

  final bool compact;

  /// The least width the card's text needs for its longest word ("Recomendaciones
  /// a tu medida") not to break: below it the compact stack is used.
  static const double minTextWidth = 170;

  static const double _bleed = 12;

  /// The stack's own width and height, full and compact.
  static const double fullWidth = 88;
  static const double fullHeight = 112;
  static const double compactWidth = 66;
  static const double compactHeight = 96;

  static const String _dir = 'assets/illustrations/taste_card';

  double get width => compact ? compactWidth : fullWidth;
  double get height => compact ? compactHeight : fullHeight;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          clipBehavior: Clip.none,
          children: compact
              ? const [
                  // Back to front: the last one is on top.
                  _Poster(
                    asset: '$_dir/poster_middle.jpg',
                    size: _Size.small,
                    right: -_bleed + 4,
                    top: 0,
                    degrees: 5,
                  ),
                  _Poster(
                    asset: '$_dir/poster_front.jpg',
                    size: _Size.small,
                    right: 14,
                    top: 16,
                    degrees: -9,
                  ),
                ]
              : const [
                  _Poster(
                    asset: '$_dir/poster_back.jpg',
                    size: _Size.regular,
                    right: -_bleed,
                    top: 0,
                    degrees: 9,
                  ),
                  _Poster(
                    asset: '$_dir/poster_middle.jpg',
                    size: _Size.regular,
                    right: 8,
                    top: 10,
                    degrees: 3,
                  ),
                  _Poster(
                    asset: '$_dir/poster_front.jpg',
                    size: _Size.regular,
                    right: 28,
                    top: 24,
                    degrees: -9,
                  ),
                ],
        ),
      ),
    );
  }
}

enum _Size {
  regular(58, 87),
  small(50, 75);

  const _Size(this.width, this.height);

  final double width;
  final double height;
}

class _Poster extends StatelessWidget {
  const _Poster({
    required this.asset,
    required this.size,
    required this.right,
    required this.top,
    required this.degrees,
  });

  final String asset;
  final _Size size;
  final double right;
  final double top;
  final double degrees;

  static const Color _shadow = Color(0x66000000);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: right,
      top: top,
      child: Transform.rotate(
        angle: degrees * math.pi / 180,
        child: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: const [
              BoxShadow(color: _shadow, blurRadius: 12, offset: Offset(0, 4)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Image.asset(
              asset,
              fit: BoxFit.cover,
              // Decoded at about its size, not the file's.
              cacheWidth: 140,
            ),
          ),
        ),
      ),
    );
  }
}
