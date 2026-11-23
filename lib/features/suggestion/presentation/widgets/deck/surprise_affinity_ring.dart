import 'package:flutter/material.dart';

import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/progress_ring.dart';

/// A progress ring with the affinity in the middle ("88%"): the shared
/// [ProgressRing], which **fills** from empty to [percent] of the circle when
/// it appears (with "reduce motion" it is drawn full at once). Used on the
/// closing screen's chosen card. The number itself is there from the start.
class SurpriseAffinityRing extends StatelessWidget {
  const SurpriseAffinityRing({super.key, required this.percent});

  /// 0–100.
  final int percent;

  static const double size = 64;
  static const double _stroke = 5;

  /// The whole animation, wait included.
  static const Duration duration = ProgressRing.duration;

  @override
  Widget build(BuildContext context) {
    return ProgressRing(
      fraction: percent / 100,
      size: size,
      strokeWidth: _stroke,
      child: Text.rich(
        TextSpan(
          text: '$percent',
          style: AppTextStyles.h3,
          children: [TextSpan(text: '%', style: AppTextStyles.captionStrong)],
        ),
      ),
    );
  }
}
