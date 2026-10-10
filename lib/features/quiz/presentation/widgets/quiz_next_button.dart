import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di.dart';
import '../../../../core/domain/entities/media_key.dart';
import '../../../../core/domain/entities/result.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../match_engine/domain/participant_answers.dart';
import '../cubit/quiz_cubit.dart';
import '../cubit/quiz_state.dart';

/// "full-width 'Next' button (disabled until the step's rule is met)" —
/// step 4's own becomes "Search" (E2: "Final button 'Search'"). Only
/// resubscribes on `(step, isCurrentStepValid)`, so an edit that doesn't
/// change validity (e.g. picking a 2nd of 3 required vibes) still
/// rebuilds this (validity *did* change), but switching screens/steps
/// elsewhere never touches it needlessly. Split out of `quiz_screen.dart`
/// to keep that file within CLAUDE.md rule 11's line limit.
class QuizNextButton extends StatelessWidget {
  const QuizNextButton({
    super.key,
    required this.participantId,
    required this.onComplete,
  });

  final String participantId;
  final ValueChanged<ParticipantAnswers> onComplete;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<QuizCubit, QuizState, (int, bool)>(
      selector: (state) => (state.step, state.isCurrentStepValid),
      builder: (context, data) {
        final (step, isValid) = data;
        final isLastStep = step >= 4;
        return PrimaryButton(
          label: isLastStep
              ? context.l10n.quizSearchButton
              : context.l10n.commonNext,
          isDisabled: !isValid,
          onTap: () => _handleTap(context, isLastStep),
        );
      },
    );
  }

  Future<void> _handleTap(BuildContext context, bool isLastStep) async {
    final cubit = context.read<QuizCubit>();
    if (!isLastStep) {
      cubit.nextStep();
      return;
    }

    // "Exclude what I've already watched" (buildAnswers' own
    // watchedKeys) only matters once the toggle is on, but fetching it
    // unconditionally is simpler than threading that toggle's value
    // down here too — UserLibraryRepository.watchedKeys is already
    // exactly "used to exclude watched titles in the match engine".
    final result = await getIt<UserLibraryRepository>().watchedKeys(
      cubit.state.mediaType,
    );
    final watchedKeys = switch (result) {
      Success<List<MediaKey>>(:final value) => value.toSet(),
      Failure<List<MediaKey>>() => const <MediaKey>{},
    };

    onComplete(
      cubit.buildAnswers(
        participantId: participantId,
        watchedKeys: watchedKeys,
      ),
    );
  }
}
