import 'package:flutter/material.dart';

import '../../../core/domain/entities/release_status.dart';
import '../../../core/domain/entities/watch_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../l10n/release_status_localization.dart';
import 'justwatch_badge.dart';
import 'provider_group_box.dart';
import 'where_to_watch_footer.dart';
import 'where_to_watch_header.dart';

/// D1/D2's "Where to watch" card — Streaming / Rent / Buy groups (the
/// "Dónde ver" design): a `surfaceRaised` card with the title and, on the same
/// row when it fits, the region pill (→ H6, so the country can be changed even when it has
/// no data — then the card says so instead of disappearing); the Streaming box
/// (56 px logos with names), Rent and Buy side by side underneath (36 px
/// logos), and a footer with the hint line, the mandatory attribution under it
/// as its subtitle, and the amber [JustWatchBadge] at the right. Tapping any service opens TMDB's `link`.
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
    this.releaseStatus,
  });

  final WatchProviders providers;
  final String regionName;

  /// Tap → opens TMDB's `link` in the browser (SCREENS.md D1); the caller
  /// decides what "tap" means.
  final void Function(String link)? onProviderTap;

  /// Tap on the region name → H6.
  final VoidCallback? onRegionTap;

  /// Not out yet / only in cinemas: with no service listed, the card says why
  /// instead of a generic "not available".
  final ReleaseStatus? releaseStatus;

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
            WhereToWatchHeader(
              regionName: regionName,
              onRegionTap: onRegionTap,
            ),
            const SizedBox(height: AppSpacing.md),
            if (!providers.hasAny)
              Text(
                releaseStatus?.whereToWatchMessage(l10n) ??
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
                        dotColor: AppColors.danger,
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
            const SizedBox(height: AppSpacing.md),
            // With services: the hint, the mandatory attribution under it as
            // its subtitle, and the badge at the right. Without: the
            // attribution alone, as its own last line.
            if (providers.hasAny)
              const WhereToWatchFooter()
            else
              const WhereToWatchAttribution(),
          ],
        ),
      ),
    );
  }
}
