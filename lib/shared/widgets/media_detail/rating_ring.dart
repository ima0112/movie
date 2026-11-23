import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../l10n/number_format_extension.dart';
import '../progress_ring.dart';

/// D1/D2's rating ring, at the right of the title: TMDB's vote average (0–10)
/// in the shared [ProgressRing] (it fills in when it appears, like the closing
/// screen's affinity ring), with the number in the middle ("9,0") and the
/// source under it ("TMDB").
///
/// It is a fixed-size badge: the number and the label ignore the system's text
/// scale (the ring would otherwise outgrow its circle), and the whole thing is
/// one semantics node reading "Rating 9.0 out of 10".
class RatingRing extends StatelessWidget {
  const RatingRing({super.key, required this.rating});

  /// TMDB's vote average, 0–10.
  final double rating;

  static const double size = 56;
  static const double _stroke = 4;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final value = rating.localizedRating(l10n);
    return Semantics(
      label: l10n.mediaDetailRatingSemantics(value),
      excludeSemantics: true,
      child: MediaQuery.withNoTextScaling(
        child: ProgressRing(
          fraction: rating / 10,
          size: size,
          strokeWidth: _stroke,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value, style: AppTextStyles.ratingValue),
              Text(
                l10n.mediaDetailRatingSource,
                style: AppTextStyles.micro.copyWith(color: AppColors.inkMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
