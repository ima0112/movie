import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/domain/entities/media_type.dart';
import '../../../match_engine/domain/participant_answers.dart';
import '../../../quiz/presentation/screens/quiz_screen.dart';
import '../cubit/surprise_cubit.dart';
import '../cubit/surprise_state.dart';

/// E2 (the shared quiz), reached only from [ChooseTypeScreen]'s own
/// `BlocListener` once [cubit] emits `NeedsQuiz` — `docs/SCREENS.md` E2:
/// "Access: E1 with no profile". [cubit]'s current state is always
/// `NeedsQuiz` by the time this screen builds, so its `mediaType` is
/// read straight from there rather than needing a second `extra`.
///
/// This is exactly the kind of caller `QuizScreen`'s own doc comment
/// anticipated: [onComplete] just forwards the finished answers to
/// [cubit] and moves on — `QuizScreen` itself still knows nothing about
/// Surprise-me specifically.
class SurpriseQuizScreen extends StatelessWidget {
  const SurpriseQuizScreen({super.key, required this.cubit});

  final SurpriseCubit cubit;

  @override
  Widget build(BuildContext context) {
    final state = cubit.state;
    final mediaType = state is NeedsQuiz ? state.mediaType : MediaType.movie;

    return QuizScreen(
      mediaType: mediaType,
      onComplete: (answers) => _onComplete(context, answers),
    );
  }

  // cubit.answerWith emits Searching synchronously, before its first
  // `await` — so by the time this push actually builds E3, `cubit.state`
  // is already `Searching`, no need to await the full round-trip first.
  // pushReplacement (not push): once the quiz is done, the native back
  // gesture from E3 should land on E1, not re-open a completed quiz.
  void _onComplete(BuildContext context, ParticipantAnswers answers) {
    cubit.answerWith(answers);
    context.pushReplacement(AppRoutes.surpriseResult, extra: cubit);
  }
}
