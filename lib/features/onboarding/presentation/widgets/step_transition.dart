import 'package:flutter/widgets.dart';

/// A2's own step-change animation — `docs/DESIGN_SYSTEM.md` section 7:
/// "Transición entre pasos (onboarding, cuestionario): 250 ms, desliza
/// 24 px + fundido." Shared because [NameStep] and `genre_step.dart`'s
/// `GenreStep` both need it and no screen exists yet to own an
/// `AnimatedSwitcher` around them (`quiz_screen.dart` doesn't implement
/// this either, so there's no cross-feature precedent to call into
/// instead — see `quiz_step_content.dart`, a bare `switch` with no
/// transition at all).
///
/// Plays once, on mount: slides up 24 px while fading in over 250 ms.
/// Respects "reduce motion" (CLAUDE.md rule 6's accessibility table) by
/// skipping straight to the end state, the same `MediaQuery.of(context)
/// .disableAnimations` check `SkeletonBlock` already uses.
class StepTransition extends StatefulWidget {
  const StepTransition({super.key, required this.child});

  final Widget child;

  static const Duration duration = Duration(milliseconds: 250);
  static const double _slideDistance = 24;

  @override
  State<StepTransition> createState() => _StepTransitionState();
}

class _StepTransitionState extends State<StepTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: StepTransition.duration,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // MediaQuery isn't available in initState; this runs once right
    // before the first build, so the entrance still plays on mount.
    if (_started) return;
    _started = true;
    if (MediaQuery.of(context).disableAnimations) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeOut.transform(_controller.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * StepTransition._slideDistance),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
