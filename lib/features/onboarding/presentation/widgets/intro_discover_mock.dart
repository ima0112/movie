import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/domain/entities/media_segment.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/media_segment_localization.dart';
import '../../../../shared/widgets/app_wordmark.dart';

/// The first slide's mini Discover, drawn inside the phone frame: the
/// wordmark, segment chips, a hero card and two poster rows. Positions
/// follow the "Onboarding 1 · Descubre" design.
class IntroDiscoverMock extends StatelessWidget {
  const IntroDiscoverMock({super.key});

  static const double _chipHeight = 24;
  // Frame inner width (244) minus the 16 px side margins.
  static const double _contentWidth = 212;
  static const double _wordmarkSize = 16;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Stack(
      children: [
        // Hero card + poster rows, as artwork (no text).
        Positioned.fill(
          child: SvgPicture.asset(
            'assets/illustrations/onboarding/intro_discover.svg', // l10n-exempt: asset-path
            fit: BoxFit.fill,
          ),
        ),
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
        // The hero card's title, over the artwork's hero card (y 94-244).
        Positioned(
          left: 28,
          top: 214,
          // Sample title, not UI copy.
          child: Text(
            'The Odyssey',
            style: AppTextStyles.h3,
          ), // l10n-exempt: sample-title
        ),
        _SectionTitle(top: 262, title: l10n.carouselSectionForYou),
        _SectionTitle(
          top: 400,
          // Sample title, not UI copy.
          title: l10n.carouselSectionBecauseYouLike(
            'Inception',
          ), // l10n-exempt: sample-title
        ),
      ],
    );
  }
}

/// A carousel title; its poster row is part of the artwork.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.top, required this.title});

  final double top;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: AppSpacing.lg,
      right: AppSpacing.lg,
      top: top,
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w600),
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
