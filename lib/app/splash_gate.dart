import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import '../core/theme/app_colors.dart';
import '../features/onboarding/presentation/poster_wall_warmup.dart';
import 'app.dart';
import 'splash_screen.dart';

/// The app's real root widget — `runApp(SplashGate(preload: …))`, not
/// [PickMeApp] directly. Owns A1's own boot sequence: show
/// [SplashScreen] (the only splash the user sees: the native one is just the
/// page's dark color), wait for the preload `main.dart` already started (A1),
/// then swap to the real [PickMeApp] — a different `MaterialApp`
/// entirely, not a route inside [PickMeApp]'s own `go_router`, so the
/// splash can never be reached again by navigating (satisfies A1's "not
/// shown on warm starts" with no extra bookkeeping: once swapped, it's
/// gone from the widget tree for the rest of the process).
class SplashGate extends StatefulWidget {
  const SplashGate({super.key, required this.preload});

  /// A1's preload (`preloadApp`), already running: `main()` starts it before
  /// the first frame, so by the time the splash mounts it is partly or fully
  /// done.
  final Future<void> preload;

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

  @override
  Widget build(BuildContext context) {
    if (_ready) return const PickMeApp();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: AppColors.surface,
      home: SplashScreen(
        preload: () => widget.preload,
        warmUp: PosterWallWarmup.run,
        onFinished: () => setState(() => _ready = true),
      ),
    );
  }
}
