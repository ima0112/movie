import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../match_engine/domain/participant_answers.dart';
import '../../../match_engine/domain/vibe_catalog.dart';
import '../cubit/quiz_cubit.dart';
import '../widgets/quiz_next_button.dart';
import '../widgets/quiz_progress_indicator.dart';
import '../widgets/quiz_step_content.dart';

/// E2 (Quiz) — `docs/SCREENS.md` E2: "1 screen, 4 steps... shared with
/// the Matcher".
///
/// Deliberately the **reusable flow**, not a specific one: takes
/// [mediaType] and [onComplete] only, and calls [onComplete] with the
/// finished [ParticipantAnswers] instead of navigating anywhere itself —
/// "Exits: E3 (solo) or F3 (group)" is therefore the caller's own job
/// (Surprise me pushes E3; the Matcher, not built yet, would push its
/// own next step), never hardcoded here. [participantId] defaults to a
/// solo session's own placeholder identity — the Matcher is the one
/// caller that actually needs a real one (a room's own participant),
/// which is why this stays a constructor parameter rather than a fixed
/// value baked into [QuizCubit.buildAnswers] itself.
///
/// Thin per CLAUDE.md rule 11: provides [QuizCubit] (and, once loaded,
/// the [VibeCatalog] step 2 needs) and assembles
/// [QuizProgressIndicator]/[QuizStepContent]/[QuizNextButton], each with
/// its own narrowly-scoped subscription (CLAUDE.md rule 9) documented on
/// itself.
class QuizScreen extends StatelessWidget {
  const QuizScreen({
    super.key,
    required this.mediaType,
    required this.onComplete,
    this.participantId = 'me',
  });

  final MediaType mediaType;
  final ValueChanged<ParticipantAnswers> onComplete;
  final String participantId;

  @override
  Widget build(BuildContext context) {
    // VibeCatalog.loadFromAssets() is async (reads assets/vibes.json);
    // QuizVibeStep needs it synchronously — same FutureBuilder-before-
    // BlocProvider shape `MyTastesScreen` already uses for the identical
    // need.
    return FutureBuilder<VibeCatalog>(
      future: VibeCatalog.loadFromAssets(),
      builder: (context, snapshot) {
        final catalog = snapshot.data;
        if (catalog == null) {
          return const Scaffold(
            backgroundColor: AppColors.surface,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.ink),
            ),
          );
        }
        return BlocProvider(
          create: (_) => QuizCubit(mediaType),
          child: _QuizView(
            vibeCatalog: catalog,
            participantId: participantId,
            onComplete: onComplete,
          ),
        );
      },
    );
  }
}

class _QuizView extends StatelessWidget {
  const _QuizView({
    required this.vibeCatalog,
    required this.participantId,
    required this.onComplete,
  });

  final VibeCatalog vibeCatalog;
  final String participantId;
  final ValueChanged<ParticipantAnswers> onComplete;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(AppIcons.back, color: AppColors.ink),
          onPressed: () => _handleBack(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const QuizProgressIndicator(),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: SingleChildScrollView(
                  child: QuizStepContent(vibeCatalog: vibeCatalog),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              QuizNextButton(
                participantId: participantId,
                onComplete: onComplete,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // E2's "back button" is common to all 4 steps, but only step 1's
  // actually leaves the screen (`QuizCubit.previousStep()` exists
  // precisely so steps 2-4 go back a step instead of exiting the quiz).
  void _handleBack(BuildContext context) {
    final cubit = context.read<QuizCubit>();
    if (cubit.state.step > 1) {
      cubit.previousStep();
    } else {
      context.pop();
    }
  }
}
