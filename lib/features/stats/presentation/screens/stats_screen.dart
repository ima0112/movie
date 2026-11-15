import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di.dart';
import '../../../../core/domain/stats/stats_period.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/page_margin.dart';
import '../../../../l10n/l10n_extension.dart';
import '../cubit/stats_cubit.dart';
import '../widgets/stats_empty_state.dart';
import '../widgets/stats_empty_period.dart';
import '../widgets/stats_genre_bars.dart';
import '../widgets/stats_hero_card.dart';
import '../widgets/stats_highlights.dart';
import '../widgets/stats_period_tabs.dart';

/// Stats (C4) — pushed from B5's "See stats" link.
///
/// Implements `docs/SCREENS.md` C4. A pushed screen per the inventory's
/// navigation rule ("Every pushed screen... has a back button... and
/// hides the bottom bar"): registered on the root navigator in
/// `app/router.dart`, outside `RootShell`'s four tab branches, the same
/// way `/movie/:id` is.
///
/// Thin per CLAUDE.md rule 11: provides [StatsCubit] and assembles the
/// widgets in `../widgets/`. Two scoped rebuilders, not one screen-wide
/// `BlocBuilder` (rule 9): [StatsTypeTabs] only needs
/// `filterType`, the content area only needs `stats` — a filter change
/// legitimately invalidates every number/bar at once, so one builder for
/// "the content" is the same shape as `DiscoverContentArea` (the one
/// deliberate content-wide builder on B1), not a violation of it.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StatsCubit(getIt<UserLibraryRepository>()),
      child: const _StatsView(),
    );
  }
}

class _StatsView extends StatelessWidget {
  const _StatsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(AppIcons.back, color: AppColors.ink),
          onPressed: () => context.pop(),
        ),
        title: Text(context.l10n.statsTitle),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenMargin,
              vertical: AppSpacing.md,
            ),
            child: BlocSelector<StatsCubit, StatsState, StatsPeriod>(
              selector: (state) => state.period,
              builder: (context, period) => StatsPeriodTabs(
                period: period,
                onSelected: context.read<StatsCubit>().selectPeriod,
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<StatsCubit, StatsState>(
              builder: (context, state) {
                final insights = state.insights;
                if (insights.watchedCount == 0) {
                  return state.period == StatsPeriod.allTime
                      ? StatsEmptyState(
                          onExploreTap: () => context.go('/explore'),
                        )
                      : const StatsEmptyPeriod();
                }
                // No side padding on the list: cards pad themselves with the
                // page margin and the highlights scroll edge to edge.
                return ListView(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.md,
                    bottom: AppSpacing.sectionGap,
                  ),
                  children: [
                    PageMargin(child: StatsHeroCard(insights: insights)),
                    StatsHighlights(insights: insights),
                    const SizedBox(height: AppSpacing.sectionGap),
                    PageMargin(
                      child: StatsGenreBars(
                        topGenres: insights.genres.take(5).toList(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
