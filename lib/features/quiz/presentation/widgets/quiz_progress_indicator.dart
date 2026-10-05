import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/quiz_cubit.dart';
import '../cubit/quiz_state.dart';
import 'quiz_progress_bar.dart';

/// "'Step X of 4' indicator" — only re-renders on a step change, never
/// on an answer edit within the same step (CLAUDE.md rule 9). Split out
/// of `quiz_screen.dart` to keep that file within CLAUDE.md rule 11's
/// line limit.
class QuizProgressIndicator extends StatelessWidget {
  const QuizProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<QuizCubit, QuizState, int>(
      selector: (state) => state.step,
      builder: (context, step) => QuizProgressBar(currentStep: step),
    );
  }
}
