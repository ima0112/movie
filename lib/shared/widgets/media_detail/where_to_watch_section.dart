import 'package:flutter/material.dart';

import '../../../core/domain/entities/watch_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/l10n_extension.dart';
import 'provider_group_box.dart';

/// D1/D2's "Where to watch" card — Streaming / Rent / Buy groups, (the
/// "Dónde ver" design): a `surfaceRaised` card with the title and a
/// JustWatch badge, the Streaming box on top (56 px logos with names), Rent
/// and Buy side by side underneath (36 px logos), and a hint line. The
/// region is a visible pill under the title (→ H6), so it can be changed
/// even when the region has no data — then the card says so instead of
/// disappearing. Tapping any service opens TMDB's `link`.
///
/// Pure presentation — [providers] arrives as a plain value (CLAUDE.md rule
/// 9 — the assembling screen already knows it's loaded).
class WhereToWatchSection extends StatelessWidget {
  const WhereToWatchSection({
    super.key,
    required this.providers,
    required this.regionName,
    this.onProviderTap,
    this.onRegionTap,
  });

  final WatchProviders providers;
  final String regionName;

  /// Tap → opens TMDB's `link` in the browser (SCREENS.md D1); the caller
  /// decides what "tap" means.
  final void Function(String link)? onProviderTap;

  /// Tap on the region name → H6.
  final VoidCallback? onRegionTap;

  static const int _maxStreaming = 5;
  static const int _maxRentBuy = 3;
  static const double _streamingTile = 56;
  // 36 px so three logos fit one row inside a half-width box (320 px phones).
  static const double _rentBuyTile = 36;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final link = providers.link;
    final onTap = link == null ? null : () => onProviderTap?.call(link);

    return Padding(
      padding: AppSpacing.sectionPadding,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(l10n.whereToWatchTitle, style: AppTextStyles.h2),
                ),
                const _JustWatchBadge(),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _RegionButton(name: regionName, onTap: onRegionTap),
            const SizedBox(height: AppSpacing.md),
            if (!providers.hasAny)
              Text(
                l10n.whereToWatchNoProviders(regionName),
                style: AppTextStyles.body.copyWith(color: AppColors.inkMuted),
              ),
            if (providers.flatrate.isNotEmpty)
              ProviderGroupBox(
                label: l10n.whereToWatchSubscription,
                dotColor: AppColors.accent,
                providers: providers.flatrate,
                logos: providers.logos,
                tileSize: _streamingTile,
                maxVisible: _maxStreaming,
                highlighted: true,
                showNames: true,
                onTap: onTap,
              ),
            if (providers.rent.isNotEmpty || providers.buy.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (providers.rent.isNotEmpty)
                    Expanded(
                      child: ProviderGroupBox(
                        label: l10n.whereToWatchRent,
                        dotColor: AppColors.success,
                        providers: providers.rent,
                        logos: providers.logos,
                        tileSize: _rentBuyTile,
                        maxVisible: _maxRentBuy,
                        onTap: onTap,
                      ),
                    ),
                  if (providers.rent.isNotEmpty && providers.buy.isNotEmpty)
                    const SizedBox(width: AppSpacing.md),
                  if (providers.buy.isNotEmpty)
                    Expanded(
                      child: ProviderGroupBox(
                        label: l10n.whereToWatchBuy,
                        dotColor: AppColors.inkMuted,
                        providers: providers.buy,
                        logos: providers.logos,
                        tileSize: _rentBuyTile,
                        maxVisible: _maxRentBuy,
                        onTap: onTap,
                      ),
                    ),
                ],
              ),
            ],
            if (providers.hasAny) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.whereToWatchTapHint,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.inkMuted,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            // Mandatory attribution.
            Text(
              l10n.whereToWatchJustWatchAttribution,
              style: AppTextStyles.caption.copyWith(color: AppColors.inkDim),
            ),
          ],
        ),
      ),
    );
  }
}

/// The small "JustWatch" badge at the card's top right.
class _JustWatchBadge extends StatelessWidget {
  const _JustWatchBadge();

  static const double _height = 28;
  static const double _iconSize = 12;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _height,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: AppColors.ink.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(AppIcons.play, size: _iconSize, color: AppColors.inkMuted),
          const SizedBox(width: AppSpacing.xs + 2),
          Text(
            'JustWatch', // l10n-exempt: brand-name
            style: AppTextStyles.captionStrong.copyWith(
              color: AppColors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// The tappable country pill: globe, name and a chevron, so it reads as a
/// control (opens H6).
class _RegionButton extends StatelessWidget {
  const _RegionButton({required this.name, required this.onTap});

  final String name;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Semantics(
        button: true,
        label: context.l10n.whereToWatchChangeRegion(name),
        excludeSemantics: true,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            constraints: const BoxConstraints(minHeight: 36),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              border: Border.all(color: AppColors.lineStrong),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(AppIcons.globe, size: 16, color: AppColors.inkMuted),
                const SizedBox(width: AppSpacing.xs + 2),
                Flexible(child: Text(name, style: AppTextStyles.bodySmStrong)),
                const SizedBox(width: AppSpacing.xs),
                const Icon(
                  AppIcons.chevronDown,
                  size: 16,
                  color: AppColors.inkMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
