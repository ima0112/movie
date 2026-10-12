import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di.dart';
import '../../../../app/router.dart';
import '../../../../core/domain/repositories/taste_profile_repository.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../match_engine/domain/match_engine.dart';
import '../../../match_engine/domain/vibe_catalog.dart';
import '../../../taste_profile/domain/taste_profile_builder.dart';
import '../cubit/surprise_cubit.dart';
import '../cubit/surprise_state.dart';
import '../widgets/choose_source_sheet.dart';
import '../widgets/choose_type_cards.dart';

/// E1 (Choose type) — `docs/SCREENS.md` E1.
///
/// Entry point of the whole Surprise-me flow: creates the one
/// [SurpriseCubit] this session uses, and hands it forward to E2 (the
/// quiz wrapper) or E3 (the result screen) via `extra` on whichever
/// route its own `BlocListener` pushes — or, when usable tastes exist,
/// opens H11 in place first so the user can choose between the two.
/// E2/E3 are separate go_router routes — siblings on the same root
/// `Navigator`, not nested inside this screen's own widget tree — so a
/// local `BlocProvider` alone wouldn't reach them; this is the same
/// "same instance, handed down explicitly" reasoning `MyListTopBar`'s
/// own filter sheet already documents for an analogous case (a sheet
/// built outside this page's own subtree).
///
/// Thin per CLAUDE.md rule 11: loads `VibeCatalog` (the same
/// `FutureBuilder`-before-`BlocProvider` shape `QuizScreen`/
/// `MyTastesScreen` already use), provides the Cubit, and assembles the
/// two type cards plus the navigation `BlocListener`.
class ChooseTypeScreen extends StatelessWidget {
  const ChooseTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          create: (_) => SurpriseCubit(
            getIt<MatchEngine>(),
            TasteProfileBuilder(catalog),
            getIt<TasteProfileRepository>(),
            getIt<UserLibraryRepository>(),
          ),
          child: const _ChooseTypeView(),
        );
      },
    );
  }
}

class _ChooseTypeView extends StatefulWidget {
  const _ChooseTypeView();

  @override
  State<_ChooseTypeView> createState() => _ChooseTypeViewState();
}

class _ChooseTypeViewState extends State<_ChooseTypeView> {
  // This screen stays mounted underneath E2/E3 (both reached via
  // `context.push`, never a replace), so its own BlocListener would
  // otherwise still be alive to see every later `SurpriseResult` that
  // `another()`/`retry()` emits from E3 — re-triggering this *initial*
  // routing decision and pushing a duplicate E3 on top each time. This
  // listener's only job is the one-time choice of where to go right
  // after `chooseType()`; once made, it must never fire again.
  //
  // `ChooseSource` doesn't count as "navigated" yet — it only opens
  // H11 in place (no route pushed), so the real decision (quiz vs
  // result) still hasn't happened. `_hasNavigated` only flips once one
  // of the other three states actually fires a push, whether that's
  // straight from `chooseType()` (no usable tastes) or indirectly,
  // once the user picks an option in H11.
  bool _hasNavigated = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SurpriseCubit, SurpriseState>(
      listenWhen: (previous, current) =>
          !_hasNavigated &&
          (current is ChooseSource ||
              current is NeedsQuiz ||
              current is SurpriseResult ||
              current is SurpriseError),
      listener: (context, state) {
        if (state is ChooseSource) {
          // A sheet pushed via showModalBottomSheet is a sibling of
          // this screen's own subtree — it does NOT see this screen's
          // BlocProvider by default, so the same SurpriseCubit instance
          // has to be handed down explicitly via BlocProvider.value.
          // Same fix MyListTopBar's own filter sheet already documents
          // for the identical issue.
          final cubit = context.read<SurpriseCubit>();
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (_) => BlocProvider.value(
              value: cubit,
              child: ChooseSourceSheet(state: state),
            ),
          );
          return;
        }

        _hasNavigated = true;
        final cubit = context.read<SurpriseCubit>();
        if (state is NeedsQuiz) {
          context.push(AppRoutes.surpriseQuiz, extra: cubit);
        } else {
          context.push(AppRoutes.surpriseResult, extra: cubit);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(AppIcons.back, color: AppColors.ink),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.chooseTypeHeadline, style: AppTextStyles.h1),
                const SizedBox(height: AppSpacing.xxl),
                const ChooseTypeCards(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
