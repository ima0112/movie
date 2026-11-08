import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di.dart';
import '../../../../core/domain/repositories/settings_repository.dart';
import '../../../../core/domain/repositories/taste_profile_repository.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../cubit/settings_cubit.dart';
import '../widgets/settings_about_section.dart';
import '../widgets/settings_data_section.dart';
import '../widgets/settings_preferences_section.dart';

/// Settings (C6) — pushed from B5 (You)'s gear icon.
///
/// Implements `docs/SCREENS.md` C6. A pushed screen per the inventory's
/// navigation rule ("Every pushed screen... has a back button... and
/// hides the bottom bar"), same shell shape as `StatsScreen`/
/// `MyTastesScreen`.
///
/// Thin per CLAUDE.md rule 11: provides [SettingsCubit] (screen-local,
/// rule 10 — nothing outside C6 ever needs to read it) and assembles
/// the three sections in `../widgets/`, each already scoped to its own
/// rebuild granularity (rule 9).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsCubit(getIt<SettingsRepository>()),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

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
        title: Text(context.l10n.settingsTitle, style: AppTextStyles.h2),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          children: [
            const SettingsPreferencesSection(),
            SettingsDataSection(
              userLibraryRepository: getIt<UserLibraryRepository>(),
              tasteProfileRepository: getIt<TasteProfileRepository>(),
            ),
            const SettingsAboutSection(),
          ],
        ),
      ),
    );
  }
}
