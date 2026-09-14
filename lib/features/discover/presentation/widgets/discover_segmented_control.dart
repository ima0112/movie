import 'package:flutter/material.dart';

import '../../../../core/domain/entities/media_segment.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// All | Movies | TV Shows. Driven entirely by [segment] and [onSelected]
/// — `discover_screen.dart` owns the actual selection as local
/// `setState`, so this widget has no idea `DiscoverCubit` even exists.
/// That's deliberate: it updates instantly on tap, before `loadDiscover`
/// even resolves (CLAUDE.md rule 9).
class DiscoverSegmentedControl extends StatelessWidget {
  const DiscoverSegmentedControl({
    super.key,
    required this.segment,
    required this.onSelected,
  });

  final MediaSegment segment;
  final ValueChanged<MediaSegment> onSelected;

  static const Duration _crossFade = Duration(milliseconds: 200);

  static const _labels = {
    MediaSegment.all: 'All',
    MediaSegment.movie: 'Movies',
    MediaSegment.tvShow: 'TV Shows',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: [
          for (final value in MediaSegment.values)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: GestureDetector(
                onTap: () => onSelected(value),
                child: AnimatedContainer(
                  duration: _crossFade,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: value == segment
                        ? AppColors.ink
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  child: AnimatedDefaultTextStyle(
                    duration: _crossFade,
                    style: AppTextStyles.bodySm.copyWith(
                      color: value == segment
                          ? AppColors.surface
                          : AppColors.inkMuted,
                    ),
                    child: Text(_labels[value]!),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
