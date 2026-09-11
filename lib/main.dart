import 'package:flutter/material.dart';

import 'app/di.dart';
import 'core/theme/app_theme.dart';
import 'features/debug/presentation/design_system_debug_screen.dart';

void main() {
  setupDependencies();
  runApp(const PakoTvApp());
}

// TODO: replace with app/app.dart (MaterialApp + go_router) once routing
// is set up per docs/STRUCTURE.md. For now this boots straight into the
// design system debug screen so core/theme/ can be checked visually.
class PakoTvApp extends StatelessWidget {
  const PakoTvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PakoTV',
      themeMode: AppTheme.themeMode,
      darkTheme: AppTheme.dark,
      theme: AppTheme.dark,
      home: const DesignSystemDebugScreen(),
    );
  }
}
