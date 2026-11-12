import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di.dart';
import '../../../../app/router.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/edit_profile_sheet.dart';
import '../../../../shared/widgets/app_tab_bar.dart';
import '../widgets/my_tastes_card.dart';
import '../widgets/you_header.dart';
import '../widgets/your_activity_card.dart';

/// You (B5) — the user's own profile, tastes summary, and activity.
///
/// Source of truth: `docs/SCREENS.md` B5. Thin per CLAUDE.md rule 11:
/// assembles the sub-widgets in `../widgets/`, none of which needs a
/// screen-level Cubit — [YouHeader]/`MyTastesCard` read the global
/// `UserProfileCubit`/`TasteProfileCubit` (provided once in
/// `app/app.dart`, rule 10) directly; `YourActivityCard` takes
/// [UserLibraryRepository] by constructor, resolved here via `getIt`
/// like every other screen does (`MyListScreen`, `DiscoverScreen`).
///
/// Recent Rooms (v1.1) isn't built — out of v1.0's scope (CLAUDE.md:
/// "Don't implement anything marked v1.1/v1.2"). C6 (Settings), C4
/// (Stats), and C5 (My Tastes) all push per the inventory's navigation
/// rule (back button, no bottom bar; `AppRoutes.settings`/
/// `AppRoutes.stats`/`AppRoutes.myTastes` are registered on the root
/// navigator in `app/router.dart`, the same way `/movie/:id` is).
///
/// Between-card spacing is [AppSpacing.sectionGap], the same as every other
/// screen of sections.
class YouScreen extends StatelessWidget {
  const YouScreen({super.key});

  void _openEditProfile(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const EditProfileSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        // The root shell's floating bar is accounted for in the list's own
        // bottom padding, so the page can scroll under it.
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screenMargin,
            AppSpacing.xl,
            AppSpacing.screenMargin,
            AppTabBar.scrollInset(context),
          ),
          children: [
            YouHeader(
              onEditProfile: () => _openEditProfile(context),
              onOpenSettings: () => context.push(AppRoutes.settings),
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            MyTastesCard(onTap: () => context.push(AppRoutes.myTastes)),
            const SizedBox(height: AppSpacing.sectionGap),
            YourActivityCard(
              userLibraryRepository: getIt<UserLibraryRepository>(),
              onSeeStats: () => context.push(AppRoutes.stats),
            ),
          ],
        ),
      ),
    );
  }
}
