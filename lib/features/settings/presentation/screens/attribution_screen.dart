import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../widgets/attribution_card.dart';

/// Attribution and credits (C7) — pushed from C6's About group.
///
/// Implements `docs/SCREENS.md` C7. Static content, no Cubit: a pushed
/// screen (back button, no bottom bar) in the same shell shape as
/// `SettingsScreen`.
class AttributionScreen extends StatelessWidget {
  const AttributionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(AppIcons.back, color: AppColors.ink),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.attributionTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            AttributionCard(
              providerName: 'TMDB', // l10n-exempt: brand-name
              body: l10n.attributionTmdbBody,
              detail: l10n.attributionTmdbDetail,
            ),
            const SizedBox(height: AppSpacing.lg),
            AttributionCard(
              providerName: 'JustWatch', // l10n-exempt: brand-name
              body: l10n.attributionJustWatchBody,
              detail: l10n.attributionJustWatchDetail,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              l10n.attributionFooter,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
            ),
          ],
        ),
      ),
    );
  }
}
