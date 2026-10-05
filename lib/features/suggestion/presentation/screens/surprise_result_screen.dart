import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/state_views.dart';
import '../cubit/surprise_cubit.dart';
import '../cubit/surprise_state.dart';
import '../widgets/surprise_result_content.dart';
import '../widgets/surprise_searching_content.dart';

/// E3 (Surprise me result) — `docs/SCREENS.md` E3.
///
/// Takes the already-built [cubit] (handed forward from E1/E2 via
/// `extra` — see `ChooseTypeScreen`'s own doc comment for why) and
/// re-provides it via `BlocProvider.value`, the same "same instance,
/// different part of the tree" hand-off `MyListTopBar`'s own filter
/// sheet already uses.
///
/// Thin per CLAUDE.md rule 11: the actual per-state rendering lives in
/// `SurpriseSearchingContent`/`SurpriseResultContent` (split out once
/// this file crossed the soft line limit) — this file only owns the
/// `Scaffold`/`BlocBuilder` switch and the "×" button's own navigation.
class SurpriseResultScreen extends StatelessWidget {
  const SurpriseResultScreen({super.key, required this.cubit});

  final SurpriseCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SurpriseCubit>.value(
      value: cubit,
      child: const _SurpriseResultView(),
    );
  }
}

class _SurpriseResultView extends StatelessWidget {
  const _SurpriseResultView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(AppIcons.close, color: AppColors.ink),
          onPressed: () => _returnToWhereYouWere(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: BlocBuilder<SurpriseCubit, SurpriseState>(
            builder: (context, state) {
              return switch (state) {
                Searching() => const SurpriseSearchingContent(),
                SurpriseResult() => SurpriseResultContent(state: state),
                Exhausted() => EmptyStateView(
                  title: "That's all for now",
                  body:
                      "We're out of suggestions from this search — try "
                      'again for a fresh pick.',
                  ctaLabel: 'Search again',
                  onCtaTap: () => context.read<SurpriseCubit>().retry(),
                ),
                SurpriseError(:final message) => ErrorStateView(
                  title: "Couldn't find a match",
                  body: message,
                  onRetry: () => context.read<SurpriseCubit>().retry(),
                ),
                // ChoosingType/NeedsQuiz never reach E3 — only
                // ChooseTypeScreen's own BlocListener pushes here, and
                // only once the Cubit has already moved past both.
                ChoosingType() || NeedsQuiz() => const SizedBox.shrink(),
              };
            },
          ),
        ),
      ),
    );
  }

  // "×" in E3 returns to wherever you were before this whole flow (B3's
  // hub, already dismissed by the time E1 showed) — not just one level
  // up, since the stack depth varies (E1→E3 direct vs E1→E2→E3 through
  // the quiz). Popped through go_router's own `pop()` rather than a raw
  // `Navigator.popUntil`: go_router rebuilds its page stack from its own
  // internal match list on every declarative navigation, so bypassing it
  // with the imperative Navigator left that internal list stale — the
  // next push resurrected an already-"popped" E3 as a zombie route
  // underneath the new one. Looping `canPop()`/`pop()` keeps go_router's
  // own state in sync at each step, and stops correctly regardless of
  // depth since the root shell route itself is never poppable.
  void _returnToWhereYouWere(BuildContext context) {
    final router = GoRouter.of(context);
    while (router.canPop()) {
      router.pop();
    }
  }
}
