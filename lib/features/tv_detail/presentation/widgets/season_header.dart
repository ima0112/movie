import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/number_format_extension.dart';

/// D2c's top block: "Season 1" big (the `display` style) and under it one muted
/// line — "2008 · 7 episodes · ★ 8.7". No card, no poster. The year and the
/// rating are left out when TMDB has none.
class SeasonHeader extends StatelessWidget {
  const SeasonHeader({
    super.key,
    required this.title,
    required this.episodeCountLabel,
    this.year,
    this.voteAverage,
  });

  final String title;

  /// Already localized ("7 episodes").
  final String episodeCountLabel;
  final int? year;

  /// The season's TMDB rating; no star when `null`.
  final double? voteAverage;

  static const double _starSize = 14;

  @override
  Widget build(BuildContext context) {
    final rating = voteAverage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.display),
        const SizedBox(height: AppSpacing.sm),
        Text.rich(
          TextSpan(
            style: AppTextStyles.body.copyWith(color: AppColors.inkMuted),
            children: [
              if (year != null) TextSpan(text: '$year · '),
              TextSpan(text: episodeCountLabel),
              if (rating != null) ...[
                const TextSpan(text: ' · '),
                const WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Icon(
                    AppIcons.starFill,
                    size: _starSize,
                    color: AppColors.accent,
                  ),
                ),
                TextSpan(text: ' ${rating.localizedRating(context.l10n)}'),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
