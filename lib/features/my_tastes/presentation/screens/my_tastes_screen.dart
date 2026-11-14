import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/cubits/taste_profile_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../match_engine/domain/vibe_catalog.dart';
import '../cubit/my_tastes_cubit.dart';
import '../widgets/taste_avoided_genres_section.dart';
import '../widgets/taste_eras_section.dart';
import '../widgets/taste_footer.dart';
import '../widgets/taste_liked_genres_section.dart';
import '../widgets/taste_platforms_section.dart';
import '../widgets/taste_type_section.dart';
import '../widgets/taste_vibes_section.dart';

/// My Tastes (C5) — pushed from B5's My Tastes card.
///
/// Implements `docs/SCREENS.md` C5. A pushed screen per the inventory's
/// navigation rule (back button, no bottom bar): registered on the root
/// navigator in `app/router.dart`, the same way `/stats` and
/// `/movie/:id` are.
///
/// Loads [VibeCatalog] once via a `FutureBuilder` before building
/// [MyTastesCubit] — the catalog's own `loadFromAssets()` is async
/// (reads `assets/vibes.json`), and the Cubit needs it synchronously at
/// construction. [TasteProfileCubit] itself comes straight from
/// context (`context.read`): it's the global Cubit already provided in
/// `app/app.dart`, above this route entirely (CLAUDE.md rule 10).
class MyTastesScreen extends StatelessWidget {
  const MyTastesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tasteProfileCubit = context.read<TasteProfileCubit>();
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
          create: (_) => MyTastesCubit(tasteProfileCubit, catalog),
          child: const _MyTastesView(),
        );
      },
    );
  }
}

class _MyTastesView extends StatelessWidget {
  const _MyTastesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(AppIcons.back, color: AppColors.ink),
          onPressed: () => context.pop(),
        ),
        title: Text(context.l10n.myTastesTitle),
        actions: [
          // "Reset" lives in the app bar (the "Mis gustos" design), amber
          // like every text link.
          Builder(
            builder: (context) => TextButton(
              onPressed: context.read<MyTastesCubit>().reset,
              child: Text(
                context.l10n.commonReset,
                style: AppTextStyles.action,
              ),
            ),
          ),
        ],
      ),
      // Every section watches only its own slice of the state (rule 9), so
      // nothing here is a screen-wide builder.
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.sectionGap),
        children: const [
          TasteTypeSection(),
          TasteLikedGenresSection(),
          TasteAvoidedGenresSection(),
          TasteVibesSection(),
          TasteErasSection(),
          TastePlatformsSection(),
          TasteFooter(),
        ],
      ),
    );
  }
}
