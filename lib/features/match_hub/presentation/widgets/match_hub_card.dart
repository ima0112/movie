import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// One of B3's two cards (`docs/SCREENS.md` B3): a leading icon badge, a
/// title and a muted subtitle.
///
/// - [highlighted] (the active card): an amber circle with the icon in
///   [AppColors.onAccent], white title and a chevron — it opens something.
/// - Otherwise (the card that isn't available yet): a muted icon on a
///   neutral circle, a muted title and, when [pillLabel] is set, an amber
///   "Soon" pill. No chevron, no [onTap].
///
/// Pure presentation — everything comes in by parameter.
class MatchHubCard extends StatelessWidget {
  const MatchHubCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.pillLabel,
    this.highlighted = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? pillLabel;
  final bool highlighted;
  final VoidCallback? onTap;

  static const double _badge = 40;

  @override
  Widget build(BuildContext context) {
    final pill = pillLabel;
    final titleColor = highlighted ? AppColors.ink : AppColors.inkMuted;
    return Semantics(
      button: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surfaceRaised2,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.line),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: highlighted
                        ? AppColors.accent
                        : AppColors.surfaceRaised,
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox(
                    width: _badge,
                    height: _badge,
                    child: Icon(
                      icon,
                      color: highlighted
                          ? AppColors.onAccent
                          : AppColors.inkMuted,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodyStrong.copyWith(
                                color: titleColor,
                              ),
                            ),
                          ),
                          if (pill != null) ...[
                            const SizedBox(width: AppSpacing.sm),
                            _SoonPill(label: pill),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        subtitle,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (highlighted)
                  const Icon(AppIcons.chevronRight, color: AppColors.inkMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SoonPill extends StatelessWidget {
  const _SoonPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        child: Text(
          label,
          style: AppTextStyles.micro.copyWith(color: AppColors.accent),
        ),
      ),
    );
  }
}
