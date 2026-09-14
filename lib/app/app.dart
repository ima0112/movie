import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'router.dart';

/// The app's root widget. Source of truth: `docs/STRUCTURE.md`
/// (`app/app.dart` — "MaterialApp, theme, router").
class PakoTvApp extends StatelessWidget {
  const PakoTvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PakoTV',
      themeMode: AppTheme.themeMode,
      darkTheme: AppTheme.dark,
      theme: AppTheme.dark,
      routerConfig: appRouter,
    );
  }
}
