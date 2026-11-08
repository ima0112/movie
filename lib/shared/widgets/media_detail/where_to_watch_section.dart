import 'package:flutter/material.dart';

import '../../../core/domain/entities/watch_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
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
class WhereToWatchSection extends StatelessWidget {
  const WhereToWatchSection({super.key, required this.providers, this.onProviderTap});

  final WatchProviders providers;

  /// Tap → opens TMDB's `link` in the browser (SCREENS.md D1). No
  /// browser-launching dependency is wired up yet, so the caller decides
  /// what "tap" means.
  final void Function(String link)? onProviderTap;

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
          Text('Where to watch', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.md),
          if (providers.flatrate.isNotEmpty)
            _ProviderRow(
              label: 'Subscription',
              providers: providers.flatrate,
              link: providers.link,
              onTap: onProviderTap,
            ),
          if (providers.rent.isNotEmpty)
            _ProviderRow(
              label: 'Rent',
              providers: providers.rent,
              link: providers.link,
              onTap: onProviderTap,
            ),
          if (providers.buy.isNotEmpty)
            _ProviderRow(
              label: 'Buy',
              providers: providers.buy,
              link: providers.link,
              onTap: onProviderTap,
            ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Data from JustWatch',
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
              if (overflow > 0) AppChip(label: '+$overflow'),
            ],
          ),
        ],
      ),
    );
  }
}
