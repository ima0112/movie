import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../../core/theme/app_colors.dart';

/// Draws PickMe's mark — an amber card with three sparkles over a fan of two
/// cards (violet and teal) — in the design's own 160 × 160 box
/// (`assets/icon/sources/pickme-glyph.svg`), scaled to whatever it is given.
///
/// Every number below is that SVG's, so the mark stays in step with the launcher
/// icon: `test/shared/widgets/app_logo_mark_test.dart` compares them with the
/// file. Colours are `AppColors` tokens, never typed here.
class LogoMarkPainter extends CustomPainter {
  const LogoMarkPainter();

  /// The side of the design's box.
  static const double box = 160;

  /// One card of the mark: its rectangle, corner radius, the rotation (degrees)
  /// about [pivot] and the gradient it is filled with.
  static const List<LogoCard> cards = [
    LogoCard(
      rect: Rect.fromLTWH(30, 38, 62, 88),
      radius: 13,
      degrees: -17,
      pivot: Offset(61, 82),
      light: AppColors.logoVioletLight,
      dark: AppColors.logoVioletDark,
    ),
    LogoCard(
      rect: Rect.fromLTWH(68, 38, 62, 88),
      radius: 13,
      degrees: 15,
      pivot: Offset(99, 82),
      light: AppColors.logoTealLight,
      dark: AppColors.logoTealDark,
    ),
    LogoCard(
      rect: Rect.fromLTWH(47, 30, 66, 94),
      radius: 14,
      degrees: 0,
      pivot: Offset(80, 77),
      light: AppColors.logoAmberLight,
      dark: AppColors.logoAmberDark,
      middle: AppColors.accent,
    ),
  ];

  /// The thin outline inside the amber card.
  static const Rect innerRect = Rect.fromLTWH(50, 33, 60, 88);
  static const double innerRadius = 11;

  /// The three sparkles, as the SVG's path data (absolute `M`, `Q` and `Z`).
  static const String sparklesPathData =
      'M69 56Q72.8 79.2 96 83Q72.8 86.8 69 110Q65.2 86.8 42 83Q65.2 79.2 69 56Z '
      'M102 46Q103.8 57.2 115 59Q103.8 60.8 102 72Q100.2 60.8 89 59Q100.2 57.2 102 46Z '
      'M101 93Q102.4 101.6 111 103Q102.4 104.4 101 113Q99.6 104.4 91 103Q99.6 101.6 101 93Z';

  /// Where the sparkles sit on the amber card: translate, scale, translate back.
  static const Offset sparklesAt = Offset(80, 77);
  static const double sparklesScale = 0.68;
  static const Offset sparklesOrigin = Offset(78.5, 78.5);

  static const double _shadowSigma = 4;
  static const double _shadowDy = 4;
  static const double _shadowAlpha = 0.5;
  static const double _hairline = 1.2;

  /// A path from SVG data made of absolute `M`, `Q` and `Z` commands only.
  static Path pathFromData(String data) {
    final path = Path();
    final tokens = RegExp(
      r'[MQZ]|-?\d+(\.\d+)?',
    ).allMatches(data).map((m) => m.group(0)!).toList();
    var i = 0;
    double next() => double.parse(tokens[i++]);
    while (i < tokens.length) {
      switch (tokens[i++]) {
        case 'M':
          path.moveTo(next(), next());
        case 'Q':
          // A run of quadratic segments shares one command letter.
          while (i < tokens.length && !RegExp('[MQZ]').hasMatch(tokens[i])) {
            path.quadraticBezierTo(next(), next(), next(), next());
          }
        case 'Z':
          path.close();
      }
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / box, size.height / box);
    for (final card in cards) {
      _paintCard(canvas, card);
    }
    _paintInnerOutline(canvas);
    _paintGloss(canvas);
    _paintSparkles(canvas);
    canvas.restore();
  }

  void _paintCard(Canvas canvas, LogoCard card) {
    final rrect = RRect.fromRectAndRadius(
      card.rect,
      Radius.circular(card.radius),
    );
    // The shadow is offset straight down on the page, not along the card's tilt.
    canvas.save();
    canvas.translate(0, _shadowDy);
    _rotate(canvas, card);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = AppColors.shadow.withValues(alpha: _shadowAlpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, _shadowSigma),
    );
    canvas.restore();

    canvas.save();
    _rotate(canvas, card);
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = ui.Gradient.linear(
          card.rect.topLeft,
          card.rect.bottomRight,
          [card.light, ?card.middle, card.dark],
          card.middle == null ? null : const [0, 0.55, 1],
        ),
    );
    // The two cards behind get a hairline edge; the amber one is outlined
    // separately, inside.
    if (card.middle == null) {
      canvas.drawRRect(
        rrect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _hairline
          ..color = AppColors.ink.withValues(alpha: 0.2),
      );
    }
    canvas.restore();
  }

  void _rotate(Canvas canvas, LogoCard card) {
    canvas.translate(card.pivot.dx, card.pivot.dy);
    canvas.rotate(card.degrees * math.pi / 180);
    canvas.translate(-card.pivot.dx, -card.pivot.dy);
  }

  void _paintInnerOutline(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(innerRect, const Radius.circular(innerRadius)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _hairline
        ..color = AppColors.ink.withValues(alpha: 0.4),
    );
  }

  /// The soft highlight across the top of the amber card.
  void _paintGloss(Canvas canvas) {
    final gloss = Path()
      ..moveTo(61, 36)
      ..lineTo(99, 36)
      ..arcToPoint(const Offset(107, 44), radius: const Radius.circular(8))
      ..lineTo(107, 66)
      ..cubicTo(90, 58, 70, 56, 53, 60)
      ..lineTo(53, 44)
      ..arcToPoint(const Offset(61, 36), radius: const Radius.circular(8))
      ..close();
    final bounds = gloss.getBounds();
    canvas.drawPath(
      gloss,
      Paint()
        ..shader = ui.Gradient.linear(bounds.topCenter, bounds.bottomCenter, [
          AppColors.ink.withValues(alpha: 0.38),
          AppColors.ink.withValues(alpha: 0),
        ]),
    );
  }

  void _paintSparkles(Canvas canvas) {
    canvas.save();
    canvas.translate(sparklesAt.dx, sparklesAt.dy);
    canvas.scale(sparklesScale);
    canvas.translate(-sparklesOrigin.dx, -sparklesOrigin.dy);
    canvas.drawPath(
      pathFromData(sparklesPathData),
      Paint()..color = AppColors.onAccent,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(LogoMarkPainter oldDelegate) => false;
}

/// One card of [LogoMarkPainter.cards].
class LogoCard {
  const LogoCard({
    required this.rect,
    required this.radius,
    required this.degrees,
    required this.pivot,
    required this.light,
    required this.dark,
    this.middle,
  });

  final Rect rect;
  final double radius;
  final double degrees;
  final Offset pivot;
  final Color light;
  final Color dark;

  /// A third gradient stop at 55% (the amber card's [AppColors.accent]).
  final Color? middle;
}
