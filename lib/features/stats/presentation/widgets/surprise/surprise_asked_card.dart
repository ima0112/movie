import 'package:flutter/material.dart';

import '../../../../../core/data/assets/collection_catalog_loader.dart';
import '../../../../../core/domain/entities/collection_catalog.dart';
import '../../../../../core/domain/stats/surprise_insights.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../l10n/collection_localization.dart';
import '../../../../../l10n/l10n_extension.dart';
import '../../../../../l10n/vibe_localization.dart';
import '../../../../match_engine/domain/vibe_catalog.dart';
import 'surprise_stat_card.dart';
import 'surprise_stat_row.dart';

/// "What do I ask for?": the collections and vibes asked most and how often a
/// choice followed, the quiz against "use my tastes", and how often the engine
/// had to widen the search. Names come from the catalogs; an id the catalogs no
/// longer know is left out.
class SurpriseAskedCard extends StatelessWidget {
  const SurpriseAskedCard({super.key, required this.asked});

  final SurpriseAsked asked;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FutureBuilder<(CollectionCatalog, VibeCatalog)>(
      future: _catalogs(),
      builder: (context, snapshot) {
        final catalogs = snapshot.data;
        final collections = catalogs == null
            ? const <(String, SurpriseAskStat)>[]
            : [
                for (final s in asked.collections.take(SurpriseAsked.maxRows))
                  if (catalogs.$1.byId(s.id) case final c?)
                    (c.localizedName(l10n), s),
              ];
        final vibes = catalogs == null
            ? const <(String, SurpriseAskStat)>[]
            : [
                for (final s in asked.vibes.take(SurpriseAsked.maxRows))
                  if (catalogs.$2.byId(s.id) case final v?)
                    (v.localizedName(l10n), s),
              ];
        return SurpriseStatCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (collections.isNotEmpty)
                ..._group(l10n, l10n.statsSurpriseCollections, collections),
              if (vibes.isNotEmpty)
                ..._group(l10n, l10n.statsSurpriseVibes, vibes),
              Text(l10n.statsSurpriseHowYouStart, style: AppTextStyles.bodySm),
              const SizedBox(height: AppSpacing.xs),
              SurpriseStatRow(
                label: l10n.statsSurpriseViaQuiz,
                value: SurpriseStatValue(
                  l10n.statsSurpriseViaRow(
                    l10n.statsSurpriseSessions(asked.viaQuiz),
                    l10n.statsSurprisePicks(asked.chosenViaQuiz),
                  ),
                ),
              ),
              SurpriseStatRow(
                label: l10n.statsSurpriseViaTastes,
                value: SurpriseStatValue(
                  l10n.statsSurpriseViaRow(
                    l10n.statsSurpriseSessions(asked.viaTastes),
                    l10n.statsSurprisePicks(asked.chosenViaTastes),
                  ),
                ),
              ),
              if (asked.relaxedSessions > 0) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  '${l10n.statsSurpriseRelaxed(asked.relaxedSessions)} (${_steps(l10n)})',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  static Future<(CollectionCatalog, VibeCatalog)> _catalogs() async =>
      (await loadCollectionCatalog(), await VibeCatalog.loadFromAssets());

  List<Widget> _group(
    AppLocalizations l10n,
    String title,
    List<(String, SurpriseAskStat)> rows,
  ) => [
    Text(title, style: AppTextStyles.bodySm),
    const SizedBox(height: AppSpacing.xs),
    for (final (name, stat) in rows)
      SurpriseStatRow(
        label: name,
        value: SurpriseStatValue(
          l10n.statsSurpriseAskedRow(stat.sessions, stat.chosenSessions),
        ),
      ),
    const SizedBox(height: AppSpacing.lg),
  ];

  String _steps(AppLocalizations l10n) => asked.relaxations
      .map(
        (r) => switch (r.$1) {
          'lowerVoteCount' => l10n.statsSurpriseRelaxLowerVotes,
          'dropVibes' => l10n.statsSurpriseRelaxDropVibes,
          'widenYears' => l10n.statsSurpriseRelaxWidenYears,
          _ => r.$1,
        },
      )
      .join(', ');
}
