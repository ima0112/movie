import 'package:flutter/material.dart';

import '../../core/domain/entities/media_segment.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/l10n_extension.dart';
import '../../l10n/media_segment_localization.dart';

/// All | Movies | TV Shows, in one of two looks ([MediaSegmentedStyle]). Driven entirely by [segment] and [onSelected]
/// — purely presentational, so it updates instantly on tap regardless of
/// whether the caller re-fetches synchronously (`DiscoverScreen`'s own
/// local `setState`) or through a Cubit (`ExploreScreen`'s
/// `ExploreCubit.selectSegment`) (CLAUDE.md rule 9).
///
/// Promoted from `discover_segmented_control.dart` to `shared/widgets/`
/// once B2 (Explore) needed the exact same control, not just a similar
/// one — the same "second genuine consumer" bar this codebase already
/// applies to `ProfileAvatar`/`FilterSectionLabel`/`TypeFilterChips`.
/// Discover's outlined chips vs Explore's contained pill — both from the
/// design, same behavior.
enum MediaSegmentedStyle { chips, pill }

class MediaSegmentedControl extends StatelessWidget {
  const MediaSegmentedControl({
    super.key,
    required this.segment,
    required this.onSelected,
    this.style = MediaSegmentedStyle.chips,
  });

  final MediaSegment segment;
  final ValueChanged<MediaSegment> onSelected;
  final MediaSegmentedStyle style;

  static const Duration _crossFade = Duration(milliseconds: 200);
  /// Shared with every other contained-pill segmented control (My List's
  /// tabs), so they all stay the same size.
  static const double pillHeight = 40;
  static const double pillInset = 4;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: switch (style) {
        MediaSegmentedStyle.chips => Row(
          children: [
            for (final value in MediaSegment.values)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: _option(context, value, outlined: true),
              ),
          ],
        ),
        MediaSegmentedStyle.pill => Container(
          height: pillHeight,
          padding: const EdgeInsets.all(pillInset),
          decoration: BoxDecoration(
            color: AppColors.surfaceRaised,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          ),
          child: Row(
            children: [
              for (final value in MediaSegment.values)
                Expanded(child: _option(context, value, outlined: false)),
            ],
          ),
        ),
      },
    );
  }

  Widget _option(
    BuildContext context,
    MediaSegment value, {
    required bool outlined,
  }) {
    final selected = value == segment;
    return Semantics(
      button: true,
      selected: selected,
      excludeSemantics: true,
      label: value.localizedLabel(context.l10n),
      child: GestureDetector(
        onTap: () => onSelected(value),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: _crossFade,
          alignment: Alignment.center,
          padding: outlined
              ? const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                )
              : null,
          decoration: BoxDecoration(
            color: selected ? AppColors.ink : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            border: outlined && !selected
                ? Border.all(color: AppColors.lineStrong)
                : null,
          ),
          child: AnimatedDefaultTextStyle(
            duration: _crossFade,
            style: AppTextStyles.bodySm.copyWith(
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected
                  ? AppColors.surface
                  : (outlined ? AppColors.ink : AppColors.inkMuted),
            ),
            child: Text(value.localizedLabel(context.l10n)),
          ),
        ),
      ),
    );
  }
}
