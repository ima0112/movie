import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/data/assets/collection_catalog_loader.dart';
import '../../../../core/domain/entities/collection_catalog.dart';
import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../match_engine/domain/participant_answers.dart';
import '../../../match_engine/domain/vibe_catalog.dart';
import '../cubit/quiz_cubit.dart';
import '../widgets/quiz_next_button.dart';
import '../widgets/quiz_progress_indicator.dart';
import '../widgets/quiz_top_bar.dart';
import '../../../../shared/widgets/app_halo.dart';
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
      builder: (context, vibes) {
        final vibeCatalog = vibes.data;
        if (vibeCatalog == null) return const _Loading();
        return FutureBuilder<CollectionCatalog>(
          future: loadCollectionCatalog(),
          builder: (context, collections) {
            final collectionCatalog = collections.data;
            if (collectionCatalog == null) return const _Loading();
            return BlocProvider(
              create: (_) => QuizCubit(
                mediaType,
                collectionCatalog: collectionCatalog,
                vibeCatalog: vibeCatalog,
              ),
              child: _QuizView(
                mediaType: mediaType,
                vibeCatalog: vibeCatalog,
                collectionCatalog: collectionCatalog,
                participantId: participantId,
                onComplete: onComplete,
              ),
            );
          },
        );
      },
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: AppColors.surface,
    body: Center(child: CircularProgressIndicator(color: AppColors.ink)),
  );
}

class _QuizView extends StatelessWidget {
  const _QuizView({
    required this.mediaType,
    required this.vibeCatalog,
    required this.collectionCatalog,
    required this.participantId,
    required this.onComplete,
  });

  final MediaType mediaType;
  final VibeCatalog vibeCatalog;
  final CollectionCatalog collectionCatalog;
  final String participantId;
  final ValueChanged<ParticipantAnswers> onComplete;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          const Positioned(left: 0, right: 0, top: 0, child: AppHalo()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                children: [
                  QuizTopBar(
                    mediaType: mediaType,
                    onBack: () => _handleBack(context),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const QuizProgressIndicator(),
                  const SizedBox(height: AppSpacing.xl),
                  Expanded(
                    child: SingleChildScrollView(
                      child: QuizStepContent(
                        vibeCatalog: vibeCatalog,
                        collectionCatalog: collectionCatalog,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  QuizNextButton(
                    participantId: participantId,
                    onComplete: onComplete,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // E2's "back button" is common to all steps, but only step 1's
  // actually leaves the screen (`QuizCubit.previousStep()` exists
  // precisely so the later steps go back a step instead of exiting the quiz).
  void _handleBack(BuildContext context) {
    final cubit = context.read<QuizCubit>();
    if (cubit.state.step > 1) {
      cubit.previousStep();
    } else {
      context.pop();
    }
  }
}
