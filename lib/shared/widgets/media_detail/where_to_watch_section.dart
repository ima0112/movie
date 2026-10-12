import 'package:flutter/material.dart';

import '../../../core/domain/entities/watch_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/l10n_extension.dart';
import '../app_chip.dart';

/// D1/D2's "Where to watch" section — Subscription / Rent / Buy rows,
/// shown only when TMDB (via JustWatch) has data for at least one of
/// them.
///
/// Source of truth: `docs/SCREENS.md` D1 ("same as D1" for D2 — see D2's
/// own spec). Real provider logos need image URLs [WatchProviders]
/// doesn't carry yet (just names) — provider name chips are a
/// placeholder until that data exists. Pure presentation — [providers]
/// arrives as a plain value (CLAUDE.md rule 9 — the assembling screen
/// already knows it's loaded).
///
/// [regionName] is SCREENS.md D1's "title with the region in gray on
/// the right (tappable → H6)" — [onRegionTap] is `null` until H6
/// (Settings' region picker) exists at all; see the TODO on the call
/// site that leaves it that way (`docs/SCREENS.md` H6, B5's own
/// "Region" row).
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

  /// Tap → opens TMDB's `link` in the browser (SCREENS.md D1). No
  /// browser-launching dependency is wired up yet, so the caller decides
  /// what "tap" means.
  final void Function(String link)? onProviderTap;

  final VoidCallback? onRegionTap;

  static const int _maxProviders = 6;

  @override
  Widget build(BuildContext context) {
    if (!providers.hasAny) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.l10n.whereToWatchTitle, style: AppTextStyles.h2),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: GestureDetector(
                  onTap: onRegionTap,
                  child: Text(
                    regionName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.inkMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (providers.flatrate.isNotEmpty)
            _ProviderRow(
              label: context.l10n.whereToWatchSubscription,
              providers: providers.flatrate,
              link: providers.link,
              onTap: onProviderTap,
            ),
          if (providers.rent.isNotEmpty)
            _ProviderRow(
              label: context.l10n.whereToWatchRent,
              providers: providers.rent,
              link: providers.link,
              onTap: onProviderTap,
            ),
          if (providers.buy.isNotEmpty)
            _ProviderRow(
              label: context.l10n.whereToWatchBuy,
              providers: providers.buy,
              link: providers.link,
              onTap: onProviderTap,
            ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.whereToWatchJustWatchAttribution,
            style: AppTextStyles.caption.copyWith(color: AppColors.inkDim),
          ),
        ],
      ),
    );
  }
}

class _ProviderRow extends StatelessWidget {
  const _ProviderRow({
    required this.label,
    required this.providers,
    required this.link,
    required this.onTap,
  });

  final String label;
  final List<String> providers;
  final String? link;
  final void Function(String link)? onTap;

  @override
  Widget build(BuildContext context) {
    final shown = providers.take(WhereToWatchSection._maxProviders).toList();
    final overflow = providers.length - shown.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final provider in shown)
                AppChip(
                  label: provider,
                  onTap: link == null ? null : () => onTap?.call(link!),
                ),
              if (overflow > 0)
                AppChip(label: context.l10n.whereToWatchOverflowChip(overflow)),
            ],
          ),
        ],
      ),
    );
  }
}
