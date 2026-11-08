import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di.dart';
import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../cubit/stats_cubit.dart';
import '../widgets/stats_activity_strip.dart';
import '../widgets/stats_empty_state.dart';
import '../widgets/stats_genre_bars.dart';
import '../widgets/stats_metric_grid.dart';
import '../widgets/stats_type_filter_chips.dart';

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
/// `BlocBuilder` (rule 9): [StatsTypeFilterChips] only needs
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
        title: Text(context.l10n.statsTitle, style: AppTextStyles.h2),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            child: BlocSelector<StatsCubit, StatsState, MediaType?>(
              selector: (state) => state.filterType,
              builder: (context, filterType) => StatsTypeFilterChips(
                filterType: filterType,
                onSelected: context.read<StatsCubit>().selectFilter,
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<StatsCubit, StatsState>(
              builder: (context, state) {
                final stats = state.stats;
                if (stats.moviesWatched == 0 && stats.tvShowsWatched == 0) {
                  return StatsEmptyState(
                    onExploreTap: () => context.go('/explore'),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  children: [
                    StatsMetricGrid(stats: stats),
                    const SizedBox(height: AppSpacing.xxl),
                    StatsGenreBars(topGenres: stats.topGenres),
                    const SizedBox(height: AppSpacing.xxl),
                    StatsActivityStrip(monthlyActivity: stats.monthlyActivity),
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
