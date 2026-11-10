import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/l10n_extension.dart';
import 'provider_logo_tile.dart';

/// One availability group inside the Where-to-watch card (Streaming, Rent
/// or Buy): a small dotted uppercase label over a wrap of provider tiles,
/// capped at [maxVisible] with a "+N" tile. [highlighted] is the Streaming
/// box — an amber border and faint tint — the others are neutral.
class ProviderGroupBox extends StatelessWidget {
  const ProviderGroupBox({
    super.key,
    required this.label,
    required this.dotColor,
    required this.providers,
    required this.logos,
    required this.tileSize,
    required this.maxVisible,
    this.highlighted = false,
    this.showNames = false,
    this.onTap,
  });

  final String label;
  final Color dotColor;
  final List<String> providers;
  final Map<String, String> logos;
  final double tileSize;
  final int maxVisible;
  final bool highlighted;
  final bool showNames;
  final VoidCallback? onTap;

  static const double _dot = 6;
  static const double _borderAlpha = 0.4;
  static const double _tintAlpha = 0.04;

  @override
  Widget build(BuildContext context) {
    final shown = providers.take(maxVisible).toList();
    final overflow = providers.length - shown.length;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: highlighted
            ? AppColors.accent.withValues(alpha: _tintAlpha)
            : null,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: highlighted
              ? AppColors.accent.withValues(alpha: _borderAlpha)
              : AppColors.glassBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: _dot,
                height: _dot,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.xs + 2),
              Flexible(
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.overline.copyWith(
                    color: highlighted ? AppColors.accent : AppColors.inkMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            // Tighter for the small Rent/Buy logos so three fit one row.
            spacing: showNames ? AppSpacing.md : AppSpacing.sm - 2,
            runSpacing: AppSpacing.md,
            children: [
              for (final name in shown)
                ProviderLogoTile(
                  name: name,
                  logoUrl: logos[name],
                  size: tileSize,
                  showName: showNames,
                  onTap: onTap,
                ),
              if (overflow > 0)
                SizedBox(
                  width: tileSize,
                  height: tileSize,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceRaised2,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusMd - 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        context.l10n.whereToWatchOverflowChip(overflow),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
