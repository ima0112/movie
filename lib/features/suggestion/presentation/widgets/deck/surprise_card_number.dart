import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/outlined_text.dart';

/// A Surprise-me card's number ("01"–"05") — big, outline only — centred on two
/// concentric outline circles that decorate the card's top-left corner. The
/// number is the card's identity for the whole session: card 3 stays 3 however
/// the deck turns.
class SurpriseCardNumber extends StatelessWidget {
  const SurpriseCardNumber({super.key, required this.number});

  /// 1-based.
  final int number;

  /// How far the rings' box sticks out past the card's corner, so the circles
  /// are cut by it like a decoration, not drawn whole.
  static const double overhang = 40;

  static const double _outerRing = 150;
  static const double _innerRing = 94;
  static const double _ringStroke = 1.5;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: _outerRing,
        height: _outerRing,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            const _Ring(
              size: _outerRing,
              color: AppColors.surpriseCardRingSoft,
            ),
            const _Ring(size: _innerRing, color: AppColors.surpriseCardRing),
            OutlinedText(
              NumberFormat('00').format(number),
              style: AppTextStyles.deckNumber,
              strokeWidth: _ringStroke + 0.5,
            ),
          ],
        ),
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: SurpriseCardNumber._ringStroke),
      ),
      child: SizedBox(width: size, height: size),
    );
  }
}
