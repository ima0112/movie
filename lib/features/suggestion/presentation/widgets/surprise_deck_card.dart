import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// One "?" card of Surprise me's searching screen (E3a): a 150×214 rounded
/// card with a 160° [colors] gradient, a hairline border, a soft shadow, two
/// ring outlines in its top-left corner and a large amber "?" in the middle.
/// The same widget serves all five cards of the fan — only [colors] differ.
///
/// Pure presentation — everything comes in by parameter.
class SurpriseDeckCard extends StatelessWidget {
  const SurpriseDeckCard({super.key, required this.colors});

  final List<Color> colors;

  static const double width = 150;
  static const double height = 214;
  static const double _radius = 22;
  static const double _questionOpacity = 0.9;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: const [
          BoxShadow(
            color: AppColors.surpriseCardShadow,
            blurRadius: 34,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    // CSS 160deg: toward the bottom, tilted slightly left.
                    begin: const Alignment(0.34, -1),
                    end: const Alignment(-0.34, 1),
                    colors: colors,
                  ),
                ),
              ),
              const Positioned(
                left: -30,
                top: -30,
                child: _Ring(size: 110, color: AppColors.surpriseCardRing),
              ),
              const Positioned(
                left: -6,
                top: -6,
                child: _Ring(size: 62, color: AppColors.surpriseCardRingSoft),
              ),
              Center(
                child: Opacity(
                  opacity: _questionOpacity,
                  child: Text('?', style: AppTextStyles.surpriseQuestion),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_radius),
                  border: Border.all(color: AppColors.surpriseCardBorder),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.size, required this.color});

  final double size;
  final Color color;

  static const double _stroke = 1.5;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: _stroke),
      ),
      child: SizedBox(width: size, height: size),
    );
  }
}
