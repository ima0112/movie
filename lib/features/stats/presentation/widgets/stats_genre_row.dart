import 'package:flutter/material.dart';

import '../../../../core/domain/entities/genre.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/genre_icons.dart';
import '../../../../l10n/genre_localization.dart';
import '../../../../l10n/l10n_extension.dart';

/// One row of C4's genres list: the genre's icon, its name, a thin bar scaled
/// to the top genre ([fraction], 0–1) and its [percent] of the genres counted.
class StatsGenreRow extends StatelessWidget {
  const StatsGenreRow({
    super.key,
    required this.genre,
    required this.percent,
    required this.fraction,
  });

  final Genre genre;
  final int percent;
  final double fraction;

  static const double _nameWidth = 104;
  static const double _percentWidth = 40;
  static const double _bar = AppSpacing.xs;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(genreIconOf(genre), color: AppColors.accent),
          const SizedBox(width: AppSpacing.md),
          SizedBox(
            width: _nameWidth,
            child: Text(
              genre.localizedName(l10n),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySm,
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              child: LinearProgressIndicator(
                value: fraction.clamp(0.0, 1.0),
                minHeight: _bar,
                color: AppColors.accent,
                backgroundColor: AppColors.surfaceRaised2,
              ),
            ),
          ),
          SizedBox(
            width: _percentWidth,
            child: Text(
              l10n.statsGenrePercent(percent),
              textAlign: TextAlign.end,
              style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
            ),
          ),
        ],
      ),
    );
  }
}
