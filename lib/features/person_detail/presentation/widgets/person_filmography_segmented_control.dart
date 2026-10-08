import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/filmography_segment_localization.dart';
import '../../../../l10n/l10n_extension.dart';
import 'filmography_grouping.dart';

/// D3's filmography filter — same visual shape as the shared
/// `MediaSegmentedControl` (All/Movies/TV Shows), not reused directly:
/// that one is fixed to `MediaSegment`'s 3 values, and this one needs a
/// 4th, conditional "As director" chip (`showAsDirector`) —
/// `FilmographySegment` has its own 4th enum value for exactly that.
class PersonFilmographySegmentedControl extends StatelessWidget {
  const PersonFilmographySegmentedControl({
    super.key,
    required this.segment,
    required this.showAsDirector,
    required this.onSelected,
  });

  final FilmographySegment segment;
  final bool showAsDirector;
  final ValueChanged<FilmographySegment> onSelected;

  static const Duration _crossFade = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final values = [
      FilmographySegment.all,
      FilmographySegment.movies,
      FilmographySegment.tvShows,
      if (showAsDirector) FilmographySegment.asDirector,
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final value in values)
            GestureDetector(
              onTap: () => onSelected(value),
              child: AnimatedContainer(
                duration: _crossFade,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: value == segment ? AppColors.ink : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
                child: AnimatedDefaultTextStyle(
                  duration: _crossFade,
                  style: AppTextStyles.bodySm.copyWith(
                    color: value == segment
                        ? AppColors.surface
                        : AppColors.inkMuted,
                  ),
                  child: Text(value.localizedLabel(context.l10n)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
