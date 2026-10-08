import 'package:flutter/material.dart';

import '../../core/domain/entities/media_segment.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/l10n_extension.dart';
import '../../l10n/media_segment_localization.dart';

/// All | Movies | TV Shows. Driven entirely by [segment] and [onSelected]
/// — purely presentational, so it updates instantly on tap regardless of
/// whether the caller re-fetches synchronously (`DiscoverScreen`'s own
/// local `setState`) or through a Cubit (`ExploreScreen`'s
/// `ExploreCubit.selectSegment`) (CLAUDE.md rule 9).
///
/// Promoted from `discover_segmented_control.dart` to `shared/widgets/`
/// once B2 (Explore) needed the exact same control, not just a similar
/// one — the same "second genuine consumer" bar this codebase already
/// applies to `ProfileAvatar`/`FilterSectionLabel`/`TypeFilterChips`.
class MediaSegmentedControl extends StatelessWidget {
  const MediaSegmentedControl({
    super.key,
    required this.segment,
    required this.onSelected,
  });

  final MediaSegment segment;
  final ValueChanged<MediaSegment> onSelected;

  static const Duration _crossFade = Duration(milliseconds: 200);

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
                    child: Text(value.localizedLabel(context.l10n)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
