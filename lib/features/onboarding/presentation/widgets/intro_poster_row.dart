import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import 'intro_mock_palette.dart';

/// Three small poster placeholders in a row — the mock Discover's
/// carousels. [offset] picks which gradients, so the two rows differ.
class IntroPosterRow extends StatelessWidget {
  const IntroPosterRow({super.key, this.offset = 0});

  final int offset;

  static const double _width = 64;
  static const double _height = 96;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.sm),
          Container(
            width: _width,
            height: _height,
            decoration: BoxDecoration(
              gradient: IntroMockPalette
                  .posters[(offset + i) % IntroMockPalette.posters.length],
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
          ),
        ],
      ],
    );
  }
}
