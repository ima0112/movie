import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/app_settings.dart';
import '../../../../core/domain/entities/country.dart';
import '../../../../shared/widgets/language_sheet.dart';
import '../../../../shared/widgets/region_sheet.dart';
import '../../../../shared/widgets/settings_row.dart';
import '../cubit/settings_cubit.dart';

/// C6's Preferences group — `docs/SCREENS.md` C6: "Language ('Español'
/// → H5), Region ('Spain' → H6, with search)". Back to plain
/// "Language", not "Content language": the stored value is now the
/// single source for both TMDB's own content language *and* the app's
/// own UI language (`PakoTvApp`'s own `locale`, in `app/app.dart`) —
/// there's only one language preference to name, not two. No Theme row
/// (no light theme in v1.0 — see `core/theme/app_theme.dart`'s own
/// `// TODO(light-theme)`) and no Family mode — see
/// `docs/decisions/family-mode-not-in-v1.md`.
///
/// Each row is its own narrowly-scoped [BlocSelector] (CLAUDE.md rule
/// 9) — picking a new region never rebuilds the Language row and vice
/// versa.
class SettingsPreferencesSection extends StatelessWidget {
  const SettingsPreferencesSection({super.key});

  void _openLanguageSheet(BuildContext context, String current) {
    final cubit = context.read<SettingsCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => LanguageSheet(
        selectedLanguageCode: current,
        onSelected: cubit.setLanguage,
      ),
    );
  }

  void _openRegionSheet(BuildContext context, String current) {
    final cubit = context.read<SettingsCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          RegionSheet(selectedRegionCode: current, onSelected: cubit.setRegion),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SettingsGroupHeader(title: 'Preferences'),
        BlocSelector<SettingsCubit, AppSettings, String>(
          selector: (settings) => settings.languageCode,
          builder: (context, languageCode) => SettingsRow(
            label: 'Language',
            value: languageCode == 'es' ? 'Español' : 'English',
            onTap: () => _openLanguageSheet(context, languageCode),
          ),
        ),
        BlocSelector<SettingsCubit, AppSettings, String>(
          selector: (settings) => settings.regionCode,
          builder: (context, regionCode) => SettingsRow(
            label: 'Region',
            value: countryName(regionCode),
            onTap: () => _openRegionSheet(context, regionCode),
          ),
        ),
      ],
    );
  }
}
