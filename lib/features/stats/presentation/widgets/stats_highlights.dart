import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/router.dart';
import '../../../../core/domain/entities/user_media_entry.dart';
import '../../../../core/domain/stats/library_insights.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/number_format_extension.dart';
import '../../../../shared/widgets/app_section.dart';
import 'stats_highlight_card.dart';

/// C4's "Highlights": a row of cards, each one fact about the user's watching
/// — the busiest month, the streak, the longest movie and show, the top rated
/// title, the Watch later backlog. A card shows only when there is something
/// to say, and the whole section when there is none. It scrolls edge to edge
/// and starts on the page margin.
///
/// Pure presentation — everything comes in as [insights].
class StatsHighlights extends StatelessWidget {
  const StatsHighlights({super.key, required this.insights});

  final LibraryInsights insights;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cards = <Widget>[
      if (insights.busiestMonth case final month?)
        StatsHighlightCard(
          leading: const StatsHighlightIcon(icon: AppIcons.calendar),
          label: l10n.statsBusiestMonth,
          value: _monthName(month, l10n),
          detail: l10n.statsTitlesCount(month.count),
        ),
      if (insights.currentStreakWeeks > 0 || insights.longestStreakWeeks > 1)
        StatsHighlightCard(
          leading: const StatsHighlightIcon(icon: AppIcons.streak),
          label: l10n.statsStreak,
          value: insights.currentStreakWeeks > 0
              ? l10n.statsWeeks(insights.currentStreakWeeks)
              : l10n.statsNoStreak,
          detail: l10n.statsBestStreak(
            l10n.statsWeeks(insights.longestStreakWeeks),
          ),
        ),
      if (insights.longestMovie case final movie?)
        _title(
          context,
          movie.entry,
          label: l10n.statsLongestMovie,
          detail: _duration(movie.minutes, l10n),
        ),
      if (insights.longestShow case final show?)
        _title(
          context,
          show.entry,
          label: l10n.statsLongestShow,
          detail:
              '${l10n.myListEpisodesCount(show.entry.episodeCount ?? 0)} · '
              '${l10n.statsHoursValue((show.minutes / 60).round().localizedCount(l10n))}',
        ),
      if (insights.bestRated case final best?)
        _title(
          context,
          best,
          label: l10n.statsBestRated,
          detail: l10n.statsStarsOfFive(best.rating!),
        ),
      if (insights.watchLaterCount > 0)
        StatsHighlightCard(
          leading: const StatsHighlightIcon(icon: AppIcons.watchLater),
          label: l10n.statsBacklog,
          value: l10n.statsTitlesCount(insights.watchLaterCount),
          detail: insights.watchLaterHours >= 1
              ? l10n.statsBacklogHours(
                  l10n.statsHoursValue(
                    insights.watchLaterHours.round().localizedCount(l10n),
                  ),
                )
              : null,
        ),
    ];
    if (cards.isEmpty) return const SizedBox.shrink();
    return AppSection(
      title: l10n.statsHighlightsTitle,
      inset: false,
      child: SizedBox(
        height: StatsHighlightCard.height,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenMargin,
          ),
          itemCount: cards.length,
          separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
          itemBuilder: (_, i) => cards[i],
        ),
      ),
    );
  }

  Widget _title(
    BuildContext context,
    UserMediaEntry entry, {
    required String label,
    required String detail,
  }) => StatsHighlightCard(
    leading: StatsHighlightPoster(posterUrl: entry.posterUrl),
    label: label,
    value: entry.title,
    detail: detail,
    onTap: () => context.pushMediaDetail(entry.key),
  );

  /// "May 2026" in the user's language, capitalised.
  static String _monthName(BusiestMonth month, AppLocalizations l10n) {
    final name = DateFormat.yMMMM(
      l10n.localeName,
    ).format(DateTime(month.year, month.month));
    return name.isEmpty ? name : name[0].toUpperCase() + name.substring(1);
  }

  static String _duration(int minutes, AppLocalizations l10n) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return h > 0
        ? l10n.myListRuntimeHoursMinutes(h, m)
        : l10n.myListRuntimeMinutesOnly(m);
  }
}
