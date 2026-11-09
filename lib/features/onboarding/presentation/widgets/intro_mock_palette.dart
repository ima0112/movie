import 'package:flutter/painting.dart';

/// Gradients standing in for posters/backdrops in the intro slides'
/// phone illustrations. Purely decorative (the illustrations are
/// excluded from semantics) and deliberately not design-system tokens:
/// they are not UI colors, just the placeholder "artwork" the design
/// uses so the slides need no image assets.
class IntroMockPalette {
  const IntroMockPalette._();

  static const LinearGradient heroWarm = LinearGradient(
    begin: Alignment(-0.5, -1),
    end: Alignment(0.5, 1),
    stops: [0, 0.5, 1],
    colors: [Color(0xFF6A4624), Color(0xFF2C1B12), Color(0xFF101014)],
  );

  static const LinearGradient backdropTeal = LinearGradient(
    begin: Alignment(-0.5, -1),
    end: Alignment(0.5, 1),
    stops: [0, 0.55, 1],
    colors: [Color(0xFF2F5A6B), Color(0xFF12222A), Color(0xFF241A1C)],
  );

  static final List<LinearGradient> posters = [
    for (final (from, to) in const [
      (Color(0xFF2F4A6B), Color(0xFF16202E)),
      (Color(0xFF6B2F3A), Color(0xFF2A1218)),
      (Color(0xFF2F6B58), Color(0xFF12261F)),
      (Color(0xFF5B4A8A), Color(0xFF1D1830)),
      (Color(0xFF6B5A2F), Color(0xFF2A2210)),
      (Color(0xFF3A3A6B), Color(0xFF14142A)),
    ])
      LinearGradient(
        begin: const Alignment(-0.5, -1),
        end: const Alignment(0.5, 1),
        colors: [from, to],
      ),
  ];
}
