import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../l10n/l10n_extension.dart';
import 'surprise_tap_marker.dart';
import 'surprise_tour_card.dart';
import 'surprise_tour_swipe_demo.dart';

/// Surprise me's first-time tour (`docs/SCREENS.md` E3), over the deck: a dimmed
/// scrim that takes every touch, a picture for the step and a text card —
/// 1. swipe to pass (the edge arrows), 2. tap to turn the card over ("1×"),
/// 3. double-tap to choose ("2×"). "Skip" and "Got it" both call [onFinished]
/// (leaving counts as having seen it); "Next"/"Back" move between steps.
///
/// The step is this widget's own tiny state: nothing outside it cares.
class SurpriseTourOverlay extends StatefulWidget {
  const SurpriseTourOverlay({super.key, required this.onFinished});

  final VoidCallback onFinished;

  static const int steps = 3;

  @override
  State<SurpriseTourOverlay> createState() => _SurpriseTourOverlayState();
}

class _SurpriseTourOverlayState extends State<SurpriseTourOverlay> {
  int _step = 0;

  static const double _scrimAlpha = 0.82;

  void _go(int step) => setState(() => _step = step);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (title, body) = switch (_step) {
      0 => (l10n.surpriseTourSwipeTitle, l10n.surpriseTourSwipeBody),
      1 => (l10n.surpriseTourFlipTitle, l10n.surpriseTourFlipBody),
      _ => (l10n.surpriseTourChooseTitle, l10n.surpriseTourChooseBody),
    };
    final picture = switch (_step) {
      0 => const SurpriseTourSwipeDemo(key: ValueKey('swipe')),
      1 => const SurpriseTapMarker(key: ValueKey('tap'), label: '1×'),
      _ => const SurpriseTapMarker(key: ValueKey('double'), label: '2×'),
    };

    return Stack(
      fit: StackFit.expand,
      children: [
        // The scrim: nothing underneath can be touched during the tour.
        ModalBarrier(
          dismissible: false,
          color: AppColors.surface.withValues(alpha: _scrimAlpha),
        ),
        Positioned.fill(
          bottom: MediaQuery.sizeOf(context).height * 0.45,
          child: picture,
        ),
        SafeArea(
          child: Align(
            alignment: const Alignment(0, 0.35),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenMargin,
              ),
              child: SurpriseTourCard(
                title: title,
                body: body,
                step: _step,
                steps: SurpriseTourOverlay.steps,
                onSkip: widget.onFinished,
                onBack: () => _go(_step - 1),
                onNext: () => _go(_step + 1),
                onDone: widget.onFinished,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
