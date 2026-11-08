import 'package:flutter/material.dart';

import '../../../../app/di.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/edit_profile_sheet.dart';
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
/// "Don't implement anything marked v1.1/v1.2"). C4 (Stats), C5 (My
/// Tastes), and C6 (Settings) don't exist yet either, so their three
/// tap targets below are no-ops for now, same as [YouHeader]'s own
/// `onOpenSettings`.
///
/// Between-card spacing uses [AppSpacing.xxl], not `xxxl` — that token's
/// own doc comment ties it specifically to Discover's sections, and this
/// isn't Discover.
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
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            YouHeader(
              onEditProfile: () => _openEditProfile(context),
              onOpenSettings: () {},
            ),
            const SizedBox(height: AppSpacing.xxl),
            MyTastesCard(onTap: () {}),
            const SizedBox(height: AppSpacing.xxl),
            YourActivityCard(
              userLibraryRepository: getIt<UserLibraryRepository>(),
              onSeeStats: () {},
            ),
          ],
        ),
      ),
    );
  }
}
