import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// [text] drawn as an **outline**: a stroke in [strokeColor] around a very
/// faint fill, so the number or word reads as a hollow, poster-like glyph
/// over any artwork. Used for the big rank numbers of B2's "Top today".
///
/// Takes its size and weight from [style] (an `AppTextStyles` token); the
/// stroke is drawn with a `Paint`, which is why this is its own widget.
class OutlinedText extends StatelessWidget {
  const OutlinedText(
    this.text, {
    super.key,
    required this.style,
    this.strokeColor = AppColors.ink,
    this.strokeWidth = 2.5,
    this.fillOpacity = 0.12,
  });

  final String text;
  final TextStyle style;
  final Color strokeColor;
  final double strokeWidth;

  /// How strong the interior fill is (0 = fully hollow).
  final double fillOpacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          text,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..strokeJoin = StrokeJoin.round
              ..color = strokeColor,
          ),
        ),
        Text(
          text,
          style: style.copyWith(
            color: strokeColor.withValues(alpha: fillOpacity),
          ),
        ),
      ],
    );
  }
}
