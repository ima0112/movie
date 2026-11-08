import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/domain/repositories/taste_profile_repository.dart';
import '../core/domain/repositories/user_profile_repository.dart';
import '../core/theme/app_theme.dart';
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
class PakoTvApp extends StatelessWidget {
  const PakoTvApp({super.key});

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
        routerConfig: appRouter,
      ),
    );
  }
}
