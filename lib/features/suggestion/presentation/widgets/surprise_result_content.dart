import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_snack_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/domain/entities/surprise_history_entry.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../cubit/surprise_cubit.dart';
import '../cubit/surprise_state.dart';
import 'surprise_result_card.dart';

/// E3's own loaded result — `docs/SCREENS.md` E3: headline, subtitle
/// (per [SurpriseResult.source]), the result card, an optional
/// relaxation note, and the action buttons/links.
class SurpriseResultContent extends StatelessWidget {
  const SurpriseResultContent({super.key, required this.state});

  final SurpriseResult state;

  @override
  Widget build(BuildContext context) {
    final item = state.current;
    final l10n = context.l10n;
    final subtitle = switch (state.source) {
      SuggestionSource.profile => l10n.surpriseSourceProfile,
      SuggestionSource.inferredList => l10n.surpriseSourceInferredList,
      SuggestionSource.quiz => l10n.surpriseSourceQuiz,
    };

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.surpriseYourSuggestionTitle, style: AppTextStyles.h1),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
          ),
          const SizedBox(height: AppSpacing.xl),
          SurpriseResultCard(
            item: item,
            onViewDetails: () {
              context.read<SurpriseCubit>().recordOutcome(
                SurpriseOutcome.revisited,
              );
              context.pushMediaDetail(item.key);
            },
          ),
          if (state.relaxations.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            // E3's own "We widened the search to 1990" is this specific
            // — MatchResult only carries *which* Relaxation steps fired,
            // not the final widened value, so this stays a generic note
            // rather than a fabricated number.
            // TODO: thread the final MatchQuery's own yearFrom through
            // MatchResult so this can show the real figure.
            Text(
              l10n.surpriseRelaxedSearchNote,
              style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: l10n.surpriseAddToWatchLater,
            onTap: () => _addToWatchLater(context),
          ),
          const SizedBox(height: AppSpacing.md),
          SecondaryButton(
            label: l10n.surpriseAnotherSuggestion,
            onTap: () => context.read<SurpriseCubit>().next(),
          ),
          // The deck is circular now — it never runs out — so a new batch is
          // asked for explicitly (until the card game replaces this screen).
          const SizedBox(height: AppSpacing.md),
          TextLinkButton(
            label: l10n.surpriseSearchAgain,
            onTap: () => context.read<SurpriseCubit>().reroll(),
          ),
          // Only profile/inferredList ever had a choice to begin with
          // (H11) — having just answered the quiz, there's nothing
          // left to offer. pushReplacement, not push: this replaces
          // *this* E3 with E2, so E2's own pushReplacement back to E3
          // once the quiz finishes lands on a single E3, not a second
          // one stacked on top of this one.
          if (state.source != SuggestionSource.quiz) ...[
            const SizedBox(height: AppSpacing.md),
            TextLinkButton(
              label: l10n.surpriseAnswerQuizInstead,
              onTap: () => context.pushReplacement(
                AppRoutes.surpriseQuiz,
                extra: context.read<SurpriseCubit>(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _addToWatchLater(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final message = context.l10n.surpriseAddedToWatchLaterSnackbar;
    await context.read<SurpriseCubit>().save();
    AppSnackBar.showOn(messenger, message);
  }
}
