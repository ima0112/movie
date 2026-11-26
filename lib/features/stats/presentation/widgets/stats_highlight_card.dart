import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../../../shared/widgets/image_use.dart';

/// One card of C4's "Highlights": a [leading] (a poster, or an icon on a
/// circle), a small muted [label], the [value] in semibold (a title, a number)
/// and a muted [detail] under it. Tappable ([onTap]) when it names a title.
///
/// Pure presentation — everything comes in by parameter.
class StatsHighlightCard extends StatelessWidget {
  const StatsHighlightCard({
    super.key,
    required this.leading,
    required this.label,
    required this.value,
    this.detail,
    this.onTap,
  });

  final Widget leading;
  final String label;
  final String value;
  final String? detail;
  final VoidCallback? onTap;

  static const double width = 232;
  static const double height = 112;

  /// The leading slot's size: a poster's width, an icon circle's diameter.
  static const double leadingWidth = 56;
  static const double leadingHeight = 84;

  @override
  Widget build(BuildContext context) {
    final muted = AppTextStyles.caption.copyWith(color: AppColors.inkMuted);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surfaceRaised,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                leading,
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: muted, maxLines: 1),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        value,
                        style: AppTextStyles.h3,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (detail != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          detail!,
                          style: muted,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A highlight's icon on a round `surfaceRaised2` badge (for the ones that
/// name no title).
class StatsHighlightIcon extends StatelessWidget {
  const StatsHighlightIcon({super.key, required this.icon});

  final IconData icon;

  static const double _icon = 24;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: StatsHighlightCard.leadingWidth,
      height: StatsHighlightCard.leadingWidth,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.surfaceRaised2,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: _icon, color: AppColors.accent),
      ),
    );
  }
}

/// A title's poster as a highlight's leading: rounded, or the placeholder
/// color when there is none.
class StatsHighlightPoster extends StatelessWidget {
  const StatsHighlightPoster({super.key, required this.posterUrl});

  final String? posterUrl;

  @override
  Widget build(BuildContext context) {
    final url = posterUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: SizedBox(
        width: StatsHighlightCard.leadingWidth,
        height: StatsHighlightCard.leadingHeight,
        child: AppNetworkImage(url: url, use: ImageUse.poster),
      ),
    );
  }
}
