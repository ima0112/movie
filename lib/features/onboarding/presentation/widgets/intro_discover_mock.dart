import 'package:flutter/material.dart';

import '../../../../core/domain/entities/media_segment.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/media_segment_localization.dart';
import '../../../../shared/widgets/app_wordmark.dart';
import 'intro_mock_palette.dart';
import 'intro_poster_row.dart';

/// The first slide's mini Discover, drawn inside the phone frame: the
/// wordmark, segment chips, a hero card and two poster rows. Positions
/// follow the "Onboarding 1 · Descubre" design.
class IntroDiscoverMock extends StatelessWidget {
  const IntroDiscoverMock({super.key});

  static const double _chipHeight = 24;
  // Frame inner width (244) minus the 16 px side margins.
  static const double _contentWidth = 212;
  static const double _heroHeight = 150;
  static const double _wordmarkSize = 16;
  static const double _heroRadius = 14;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Stack(
      children: [
        const Positioned(
          left: AppSpacing.lg,
          top: 22,
          child: AppWordmark(fontSize: _wordmarkSize),
        ),
        Positioned(
          left: AppSpacing.lg,
          top: 56,
          // Shrinks the row to the phone's width if labels run long.
          child: SizedBox(
            width: _contentWidth,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  for (final segment in MediaSegment.values) ...[
                    _MockChip(
                      label: segment.localizedLabel(l10n),
                      selected: segment == MediaSegment.all,
                    ),
                    const SizedBox(width: 6),
                  ],
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: 94,
          height: _heroHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: IntroMockPalette.heroWarm,
              borderRadius: BorderRadius.circular(_heroRadius),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                // Sample title, not UI copy.
                child: Text(
                  'The Odyssey',
                  style: AppTextStyles.h3,
                ), // l10n-exempt: sample-title
              ),
            ),
          ),
        ),
        _Section(top: 262, title: l10n.carouselSectionForYou, offset: 0),
        _Section(
          top: 400,
          // Sample title, not UI copy.
          title: l10n.carouselSectionBecauseYouLike(
            'Inception',
          ), // l10n-exempt: sample-title
          offset: 3,
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.top,
    required this.title,
    required this.offset,
  });

  final double top;
  final String title;
  final int offset;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: AppSpacing.lg,
      right: AppSpacing.lg,
      top: top,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          IntroPosterRow(offset: offset),
        ],
      ),
    );
  }
}

class _MockChip extends StatelessWidget {
  const _MockChip({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: IntroDiscoverMock._chipHeight,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? AppColors.ink : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: selected ? null : Border.all(color: AppColors.lineStrong),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: selected ? AppColors.surface : AppColors.ink,
        ),
      ),
    );
  }
}
