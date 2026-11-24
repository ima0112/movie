import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../shared/widgets/app_halo.dart';
import '../shared/widgets/app_logo_mark.dart';
import '../shared/widgets/app_wordmark.dart';

/// A1 (Splash) — `docs/SCREENS.md`: PickMe's mark sits over an amber halo, the
/// "PickMe" wordmark unfurls under it, then the wordmark slides into its spot on
/// Home. The native splash (`flutter_native_splash.yaml`) already shows the same
/// mark, centered and at the same size, so this one **starts with the mark in
/// place** — it doesn't fade in — and only the halo and the wordmark are new:
/// nothing jumps between the two.
///
/// [preload] returns A1's preload, which `main()` already started before the
/// first frame (so it is usually part-way done); it is awaited when this
/// widget mounts; [onFinished]
/// fires once it's done *and* the animation has had its full ~1.3 s to
/// play, capped at [maxDuration] regardless — `docs/SCREENS.md`
/// "Duration: max 1.5 s" is a hard ceiling, not a target, so a slow
/// network never holds the splash open past it.
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.preload,
    required this.onFinished,
  });

  final Future<void> Function() preload;
  final VoidCallback onFinished;

  static const Duration wordmarkDelay = Duration(milliseconds: 500);
  static const Duration powerOffDelay = Duration(milliseconds: 900);
  static const Duration exitDuration = Duration(milliseconds: 400);
  static const Duration maxDuration = Duration(milliseconds: 1500);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _wordmarkVisible = false;
  bool _exiting = false;

  @override
  void initState() {
    super.initState();
    _run();
  }

  void _after(Duration delay, VoidCallback apply) {
    Future.delayed(delay).then((_) {
      if (mounted) setState(apply);
    });
  }

  Future<void> _run() async {
    final preloadFuture = widget.preload();
    _after(SplashScreen.wordmarkDelay, () => _wordmarkVisible = true);
    _after(SplashScreen.powerOffDelay, () {
      _exiting = true;
    });

    final fullAnimation = Future.delayed(
      SplashScreen.powerOffDelay + SplashScreen.exitDuration,
    );
    await Future.any([
      Future.wait([preloadFuture, fullAnimation]),
      Future.delayed(SplashScreen.maxDuration),
    ]);
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    // A `Scaffold` ancestor, not just `ColoredBox` — without one, `Text`
    // (here, `AppWordmark`'s two `TextSpan`s) has no `Material` ancestor
    // and falls back to Flutter's own debug `DefaultTextStyle`, whose
    // `decoration` is a double yellow underline. Fixing a single
    // `Text.decoration` wouldn't cover any other text this screen gains
    // later — the ancestor is the actual gap (CLAUDE.md rule 14).
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Align(alignment: Alignment.topCenter, child: AppHalo()),
          // The mark exactly centered, where the native splash drew it; the
          // wordmark hangs under it.
          Center(
            child: SizedBox(
              width: AppLogoMark.defaultSize,
              height: AppLogoMark.defaultSize,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const AppLogoMark(),
                  Positioned(
                    top: AppLogoMark.defaultSize,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: AnimatedSlide(
                        duration: SplashScreen.exitDuration,
                        curve: Curves.easeIn,
                        offset: _exiting ? const Offset(0, -0.6) : Offset.zero,
                        child: AnimatedOpacity(
                          duration: SplashScreen.exitDuration,
                          opacity: _wordmarkVisible && !_exiting ? 1 : 0,
                          child: const AppWordmark(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
