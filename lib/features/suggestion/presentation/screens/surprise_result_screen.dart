import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/state_views.dart';
import '../cubit/surprise_cubit.dart';
import '../cubit/surprise_state.dart';
import '../widgets/deck/surprise_closing_view.dart';
import '../widgets/deck/surprise_deck_view.dart';
import '../widgets/surprise_searching_view.dart';

/// E3 (Surprise me's deck, its searching screen and its closing screen) —
/// `docs/SCREENS.md` E3/E3a.
///
/// Takes the already-built [cubit] (handed forward from E1/E2 via `extra` — see
/// `ChooseTypeScreen`) and re-provides it with `BlocProvider.value`. Thin
/// (CLAUDE.md rule 11): it only switches between the page of each state; each
/// page is its own widget.
///
/// Leaving: the "×" and the system back both leave the whole flow from the deck
/// and the closing screen; from "Searching" they cancel the search — back to the
/// deck if there was one ("Ask for another 5"), else one step back.
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

/// Which page a state shows.
enum _Page { searching, deck, closing, error, none }

_Page _pageOf(SurpriseState s) => switch (s) {
  Searching() => _Page.searching,
  SurpriseResult() => _Page.deck,
  SurpriseChosen() => _Page.closing,
  SurpriseError() => _Page.error,
  // The Cubit moving on (a cancel on its way out): leave the page as it is.
  ChoosingType() || ChooseSource() || NeedsQuiz() => _Page.none,
};

class _SurpriseResultView extends StatelessWidget {
  const _SurpriseResultView();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave(context);
      },
      child: BlocBuilder<SurpriseCubit, SurpriseState>(
        buildWhen: (previous, current) {
          final page = _pageOf(current);
          return page != _Page.none && page != _pageOf(previous);
        },
        builder: (context, state) {
          void leave() => _leave(context);
          return switch (state) {
            Searching() => SurpriseSearchingView(onCancel: leave),
            SurpriseResult() => SurpriseDeckView(onClose: leave),
            SurpriseChosen() => SurpriseClosingView(
              chosen: state,
              onClose: leave,
            ),
            SurpriseError() => Scaffold(
              backgroundColor: AppColors.surface,
              appBar: AppBar(
                backgroundColor: AppColors.surface,
                elevation: 0,
                leading: const CloseButton(color: AppColors.ink),
                // (leading's own onPressed pops one step; the error has no
                // deck to protect.)
              ),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: ErrorStateView(
                    title: context.l10n.surpriseNoMatchTitle,
                    body: context.l10n.surpriseErrorMessage,
                    onRetry: () => context.read<SurpriseCubit>().retry(),
                  ),
                ),
              ),
            ),
            ChoosingType() ||
            ChooseSource() ||
            NeedsQuiz() => const SizedBox.shrink(),
          };
        },
      ),
    );
  }

  void _leave(BuildContext context) {
    final cubit = context.read<SurpriseCubit>();
    final state = cubit.state;
    if (state is Searching) {
      // Back to the deck it came from, if any; else one step back.
      if (!cubit.cancelSearch()) context.pop();
      return;
    }
    cubit.closeDeck();
    // Back to wherever you were before this whole flow, not one level up: the
    // depth varies (E1→E3, or E1→E2→E3 through the quiz). Looping go_router's
    // own `canPop()`/`pop()` keeps its internal match list in sync (a raw
    // `Navigator.popUntil` left it stale and resurrected a popped E3).
    final router = GoRouter.of(context);
    while (router.canPop()) {
      router.pop();
    }
  }
}
