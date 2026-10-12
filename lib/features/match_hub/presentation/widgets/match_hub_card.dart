import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// One of B3's two large cards — `docs/SCREENS.md` B3: "Large 'Surprise
/// me' card — subtitle... — icon." / "Large 'Match with friends' card —
/// subtitle... — icon."
///
/// [pillLabel] renders "Match with friends"'s own "Soon" tag — not
/// copy `docs/SCREENS.md` B3 gives verbatim (the doc assumes the
/// Matcher, v1.1, already exists), but a plain, necessary indicator
/// that it doesn't yet, same sentence-case convention as every other
/// label in this app. A card with [pillLabel] set has no [onTap], per
/// this branch's own "sin navegación" instruction — the pill alone
/// communicates "not tappable yet" without needing a separate disabled
/// visual treatment.
///
/// Pure presentation — no feature dependency, everything comes in by
/// parameter.
class MatchHubCard extends StatelessWidget {
  const MatchHubCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.pillLabel,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? pillLabel;
  final VoidCallback? onTap;

  // DESIGN_SYSTEM.md section 4's own icon-size scale tops out at 24
  // ("filas, acciones, barra de tabs") — no larger token exists for a
  // big card icon, so this reuses the closest one rather than inventing
  // a one-off size.
  static const double _iconSize = 24;

  @override
  Widget build(BuildContext context) {
    final pill = pillLabel;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Row(
          children: [
            Icon(icon, size: _iconSize, color: AppColors.ink),
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
                          style: AppTextStyles.h3,
                        ),
                      ),
                      if (pill != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        _SoonPill(label: pill),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised2,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
      ),
    );
  }
}
