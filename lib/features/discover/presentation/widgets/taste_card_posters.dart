import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

/// The taste card's illustration: three real posters stacked with different
/// tilts, hinting at the recommendations the card promises. Static, bundled
/// images (`assets/illustrations/taste_card/`) — they never change and need no
/// network. Decorative: hidden from screen readers.
class TasteCardPosters extends StatelessWidget {
  const TasteCardPosters({super.key});

  static const double _posterWidth = 70;
  static const double _posterHeight = 105;

  /// The stack's own size (the three posters, tilted, fit inside it).
  static const double width = 132;
  static const double height = 134;

  static const String _dir = 'assets/illustrations/taste_card';

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          clipBehavior: Clip.none,
          children: const [
            // Back to front: the last one is on top.
            _Poster(
              asset: '$_dir/poster_back.jpg',
              right: 0,
              top: 0,
              degrees: 9,
            ),
            _Poster(
              asset: '$_dir/poster_middle.jpg',
              right: 22,
              top: 8,
              degrees: 3,
            ),
            _Poster(
              asset: '$_dir/poster_front.jpg',
              right: 46,
              top: 22,
              degrees: -9,
            ),
          ],
        ),
      ),
    );
  }
}

class _Poster extends StatelessWidget {
  const _Poster({
    required this.asset,
    required this.right,
    required this.top,
    required this.degrees,
  });

  final String asset;
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
          width: TasteCardPosters._posterWidth,
          height: TasteCardPosters._posterHeight,
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
