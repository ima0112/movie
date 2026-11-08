import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../cubit/surprise_cubit.dart';
import '../cubit/surprise_state.dart';

/// H11 (Choose source) — `docs/SCREENS.md` H11, opened from E1's own
/// `BlocListener` once [SurpriseCubit] emits [ChooseSource] (usable
/// tastes exist — an explicit profile, or one inferred from My List).
/// Lets the user pick between using that signal directly or answering
/// the quiz (E2) instead, even though they didn't have to.
///
/// CLAUDE.md rule 9: this widget only ever reads the one [ChooseSource]
/// value its caller hands it — it never subscribes to [SurpriseCubit]
/// itself, since by the time it's shown the cubit has already moved
/// past every other state this sheet would need to react to.
class ChooseSourceSheet extends StatelessWidget {
  const ChooseSourceSheet({super.key, required this.state});

  final ChooseSource state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // ChooseSource.source is always profile or inferredList — see
    // that state's own doc comment.
    final subtitle = switch (state.source) {
      SuggestionSource.profile => l10n.surpriseSourceProfile,
      SuggestionSource.inferredList => l10n.surpriseSourceInferredList,
      SuggestionSource.quiz => throw StateError(
        'ChooseSource.source is never .quiz',
      ),
    };
    final cubit = context.read<SurpriseCubit>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.surpriseChooseSourceTitle, style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: l10n.surpriseUseMyTastes,
              onTap: () {
                cubit.useMyTastes();
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: AppSpacing.md),
            SecondaryButton(
              label: l10n.surpriseAnswerQuizInstead,
              onTap: () {
                cubit.answerQuizInstead();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
