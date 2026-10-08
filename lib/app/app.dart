import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/domain/entities/app_settings.dart';
import '../core/domain/repositories/settings_repository.dart';
import '../core/domain/repositories/taste_profile_repository.dart';
import '../core/domain/repositories/user_profile_repository.dart';
import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'cubits/taste_profile_cubit.dart';
import 'cubits/user_profile_cubit.dart';
import 'di.dart';
import 'router.dart';

/// The app's root widget. Source of truth: `docs/STRUCTURE.md`
/// (`app/app.dart` — "MaterialApp, theme, router").
///
/// Also where the app's global Cubits (CLAUDE.md rule 10) are provided,
/// above `MaterialApp.router` so every route can reach them —
/// [UserProfileCubit] and [TasteProfileCubit] today.
///
/// Also the one place that subscribes to [SettingsRepository.watch] for
/// [MaterialApp.router]'s own `locale` — CLAUDE.md rule 9 applied to the
/// root itself: a single subscription here, `.distinct()`-ed over the
/// derived [Locale] (not the whole [AppSettings]), so a region-only
/// change never triggers a rebuild. The stored language is the same
/// one `LocaleInterceptor` sends to TMDB (`SettingsRepository`'s own
/// doc comment, and `tmdbLanguageTag`) — one Settings row controls
/// both halves, not two independent preferences.
class PakoTvApp extends StatefulWidget {
  const PakoTvApp({super.key});

  @override
  State<PakoTvApp> createState() => _PakoTvAppState();
}

class _PakoTvAppState extends State<PakoTvApp> {
  late final SettingsRepository _settingsRepository =
      getIt<SettingsRepository>();
  late Locale _locale = _localeFrom(_settingsRepository.current);
  late final StreamSubscription<Locale> _localeSubscription;

  @override
  void initState() {
    super.initState();
    _localeSubscription = _settingsRepository
        .watch()
        .map(_localeFrom)
        .distinct()
        .listen((locale) => setState(() => _locale = locale));
  }

  @override
  void dispose() {
    unawaited(_localeSubscription.cancel());
    super.dispose();
  }

  static Locale _localeFrom(AppSettings settings) =>
      Locale(settings.languageCode);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => UserProfileCubit(getIt<UserProfileRepository>()),
        ),
        BlocProvider(
          create: (_) => TasteProfileCubit(getIt<TasteProfileRepository>()),
        ),
      ],
      child: MaterialApp.router(
        title: 'PakoTV',
        themeMode: AppTheme.themeMode,
        darkTheme: AppTheme.dark,
        theme: AppTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: _locale,
        routerConfig: appRouter,
      ),
    );
  }
}
