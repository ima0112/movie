import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import '../core/domain/repositories/media_repository.dart';
import '../core/domain/repositories/onboarding_repository.dart';
import '../core/domain/repositories/settings_repository.dart';
import '../core/theme/app_colors.dart';
import 'app.dart';
import 'di.dart';
import 'splash_screen.dart';

/// The app's real root widget — `runApp(const SplashGate())`, not
/// [PakoTvApp] directly. Owns A1's own boot sequence: show
/// [SplashScreen] (itself picking up from the native splash
/// `main.dart` preserved), run the preload `docs/SCREENS.md` A1 asks
/// for, then swap to the real [PakoTvApp] — a different `MaterialApp`
/// entirely, not a route inside [PakoTvApp]'s own `go_router`, so the
/// splash can never be reached again by navigating (satisfies A1's "not
/// shown on warm starts" with no extra bookkeeping: once swapped, it's
/// gone from the widget tree for the rest of the process).
class SplashGate extends StatefulWidget {
  const SplashGate({super.key});

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => FlutterNativeSplash.remove(),
    );
  }

  /// `docs/SCREENS.md` A1: "while theme, language, `/configuration`, and
  /// `/trending/all/week` load." Theme is already synchronous
  /// (`AppTheme.dark` — see `app.dart`), so three real waits remain:
  /// [OnboardingRepository] and [SettingsRepository] (both needed before
  /// `PakoTvApp`'s own router redirect, or any TMDB request, reads them)
  /// and one [MediaRepository] call, which also warms `/configuration`
  /// as a side effect — `TmdbMediaRepository`'s own `_imagesConfig`
  /// getter calls `TmdbConfigurationService.load()` on every access, so
  /// there's no need to reach that `@real`-only service directly here
  /// (and doing so would crash the `fake` environment). Without a
  /// repository-level response cache, this doesn't make Discover's
  /// *own* fetch faster — it only covers the literal "while ... load"
  /// window `docs/SCREENS.md` describes; a shared cache is a bigger,
  /// undiscussed change.
  Future<void> _preload() async {
    await Future.wait([
      getIt<OnboardingRepository>().load(),
      getIt<SettingsRepository>().load(),
      getIt<MediaRepository>().getCarouselSection(
        CarouselSection.popularThisWeek,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) return const PakoTvApp();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: AppColors.surface,
      home: SplashScreen(
        preload: _preload,
        onFinished: () => setState(() => _ready = true),
      ),
    );
  }
}
