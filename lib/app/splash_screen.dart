import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../shared/widgets/app_halo.dart';
import '../shared/widgets/app_wordmark.dart';
import '../shared/widgets/pako_state.dart';

/// A1 (Splash) — `docs/SCREENS.md`: "static native (Pako's logo, off,
/// centered on `#0B0B0D`) → Rive animation: amber halo, Pako powers on,
/// 'PakoTV' wordmark unfurls → Pako powers off and the wordmark slides
/// into its spot on Home." The native half is
/// `flutter_native_splash.yaml`; this is what takes over the instant
/// Flutter can draw its own first frame, picking up from the exact same
/// `PakoMood.off` so there's no visible jump between the two.
///
/// [preload] is awaited the moment this widget mounts; [onFinished]
/// fires once it's done *and* the animation has had its full ~1.3 s to
/// play, capped at [maxDuration] regardless — `docs/SCREENS.md`
/// "Duration: max 1.5 s" is a hard ceiling, not a target, so a slow
/// network never holds the splash open past it.
///
/// TODO(rive): replace this hand-timed mood/opacity sequence with a
/// real `RiveAnimation` driving `powerOn` — see `pako_state.dart`'s own
/// TODO for the same gap.
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.preload,
    required this.onFinished,
  });

  final Future<void> Function() preload;
  final VoidCallback onFinished;

  static const Duration powerOnDelay = Duration(milliseconds: 200);
  static const Duration wordmarkDelay = Duration(milliseconds: 500);
  static const Duration powerOffDelay = Duration(milliseconds: 900);
  static const Duration exitDuration = Duration(milliseconds: 400);
  static const Duration maxDuration = Duration(milliseconds: 1500);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  PakoMood _mood = PakoMood.off;
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
    _after(SplashScreen.powerOnDelay, () => _mood = PakoMood.idle);
    _after(SplashScreen.wordmarkDelay, () => _wordmarkVisible = true);
    _after(SplashScreen.powerOffDelay, () {
      _mood = PakoMood.off;
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
    return ColoredBox(
      color: AppColors.surface,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Align(alignment: Alignment.topCenter, child: AppHalo()),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: PakoState(key: ValueKey(_mood), mood: _mood, size: 96),
                ),
                const SizedBox(height: AppSpacing.xxl),
                AnimatedSlide(
                  duration: SplashScreen.exitDuration,
                  curve: Curves.easeIn,
                  offset: _exiting ? const Offset(0, -0.6) : Offset.zero,
                  child: AnimatedOpacity(
                    duration: SplashScreen.exitDuration,
                    opacity: _wordmarkVisible && !_exiting ? 1 : 0,
                    child: const AppWordmark(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
