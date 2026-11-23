import 'package:flutter/material.dart';

import '../../../../../core/domain/stats/surprise_insights.dart';
import '../../../../../l10n/l10n_extension.dart';
import '../../../../../shared/widgets/app_section.dart';
import 'surprise_after_choosing_card.dart';
import 'surprise_asked_card.dart';
import 'surprise_discoveries_card.dart';
import 'surprise_genres_card.dart';
import 'surprise_habit_card.dart';
import 'surprise_hit_rate_card.dart';

/// C4's Surprise-me statistics: six blocks, each drawn only when it has
/// something to say (`docs/SCREENS.md` C4). Nothing at all when the period has
/// no session.
class SurpriseStatsSection extends StatelessWidget {
  const SurpriseStatsSection({super.key, required this.insights});

  final SurpriseInsights insights;

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) return const SizedBox.shrink();
    final l10n = context.l10n;
    final hit = insights.hitRate!;
    final after = insights.afterChoosing;
    final asked = insights.asked;
    return Column(
      children: [
        AppSection(
          title: l10n.statsSurpriseTitle,
          child: SurpriseHitRateCard(hitRate: hit),
        ),
        if (after != null)
          AppSection(
            title: l10n.statsSurpriseAfterTitle,
            child: SurpriseAfterChoosingCard(after: after),
          ),
        if (insights.discoveries.isNotEmpty)
          AppSection(
            title: l10n.statsSurpriseNewTitle,
            child: SurpriseDiscoveriesCard(discoveries: insights.discoveries),
          ),
        if (insights.genres.isNotEmpty)
          AppSection(
            title: l10n.statsSurpriseGenresTitle,
            child: SurpriseGenresCard(
              genres: insights.genres,
              split: insights.typeSplit,
            ),
          ),
        if (asked != null)
          AppSection(
            title: l10n.statsSurpriseAskedTitle,
            child: SurpriseAskedCard(asked: asked),
          ),
        AppSection(
          title: l10n.statsSurpriseHabitTitle,
          child: SurpriseHabitCard(habit: insights.habit),
        ),
      ],
    );
  }
}
