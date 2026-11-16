import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di.dart';
import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/domain/repositories/media_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/accent_headline.dart';
import '../../../../shared/widgets/failure_state_view.dart';
import '../cubit/quiz_platforms_cubit.dart';
import 'quiz_all_platforms_row.dart';
import 'quiz_platform_grid.dart';
import 'quiz_rent_buy_row.dart';

/// E2 step 3 — "Which **platforms** shall we search?": an "All platforms"
/// switch (on while nothing is picked — then the search covers every service of
/// the region, not just the ones shown), the region's top streaming services as
/// a 3-column grid of logo tiles, any number picked, and the "Include rent and
/// buy" switch.
///
/// Provides its own [QuizPlatformsCubit] (the list is only needed here).
class QuizPlatformStep extends StatelessWidget {
  const QuizPlatformStep({
    super.key,
    required this.mediaType,
    required this.selected,
    required this.includeRentBuy,
    required this.onToggle,
    required this.onClear,
    required this.onIncludeRentBuyChanged,
  });

  final MediaType mediaType;
  final Set<int> selected;
  final bool includeRentBuy;
  final ValueChanged<int> onToggle;
  final VoidCallback onClear;
  final ValueChanged<bool> onIncludeRentBuyChanged;

  /// Room for the offline / error view, which is built to fill a page.
  static const double _failureHeight = 280;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocProvider(
      create: (_) => QuizPlatformsCubit(getIt<MediaRepository>(), mediaType),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AccentHeadline(
            before: l10n.quizPlatformHeadlineBefore,
            accent: l10n.quizPlatformHeadlineAccent,
            after: l10n.quizPlatformHeadlineAfter,
          ),
          const SizedBox(height: AppSpacing.xl),
          QuizAllPlatformsRow(
            allSelected: selected.isEmpty,
            onSelectAll: onClear,
          ),
          const SizedBox(height: AppSpacing.md),
          BlocBuilder<QuizPlatformsCubit, QuizPlatformsState>(
            builder: (context, state) => switch (state) {
              QuizPlatformsLoading() => const QuizPlatformGrid.loading(),
              QuizPlatformsLoaded(:final services) when services.isEmpty =>
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: Text(
                    l10n.quizPlatformNone,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.inkMuted,
                    ),
                  ),
                ),
              QuizPlatformsLoaded(:final services) => QuizPlatformGrid(
                services: services,
                selected: selected,
                onToggle: onToggle,
              ),
              QuizPlatformsError(:final reason) => SizedBox(
                height: _failureHeight,
                child: FailureStateView(
                  reason: reason,
                  onRetry: () => context.read<QuizPlatformsCubit>().load(),
                ),
              ),
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          QuizRentBuyRow(
            value: includeRentBuy,
            onChanged: onIncludeRentBuyChanged,
          ),
        ],
      ),
    );
  }
}
