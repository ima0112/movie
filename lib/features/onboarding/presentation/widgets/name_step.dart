import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/pako_state.dart';
import 'name_step_form.dart';
import 'onboarding_scaffold.dart';
import 'step_transition.dart';

/// Step 1 — `docs/SCREENS.md` A2: "required, no 'Skip'". Mirrors
/// `EditProfileSheet`'s own layout and copy (the doc's own "same
/// controls" note), plus this task's own addition: Pako plays
/// [PakoMood.celebrate] once, the moment the name first becomes valid.
///
/// Pure presentation (CLAUDE.md rule 9): [name]/[initialColor]/[isValid]
/// come from `OnboardingCubit`'s state via whatever screen assembles
/// this step (not built yet); this widget never reads the Cubit itself.
class NameStep extends StatefulWidget {
  const NameStep({
    super.key,
    required this.name,
    required this.initialColor,
    required this.isValid,
    required this.onNameChanged,
    required this.onColorChanged,
    required this.onNext,
  });

  final String name;
  final int? initialColor;
  final bool isValid;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<int> onColorChanged;
  final VoidCallback onNext;

  @override
  State<NameStep> createState() => _NameStepState();
}

class _NameStepState extends State<NameStep> {
  late final TextEditingController _controller;
  bool _hasCelebrated = false;
  PakoMood _mood = PakoMood.idle;
  Timer? _celebrateTimer;

  static const Duration _celebrateDuration = Duration(milliseconds: 900);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.name);
    // Already valid on first build (e.g. coming back to this step) —
    // treat the celebration as already spent, don't replay it.
    _hasCelebrated = widget.isValid;
  }

  @override
  void didUpdateWidget(NameStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.name != _controller.text) {
      _controller.value = _controller.value.copyWith(
        text: widget.name,
        selection: TextSelection.collapsed(offset: widget.name.length),
      );
    }
    final wasShortEnough = oldWidget.name.trim().length < 2;
    final isLongEnoughNow = widget.name.trim().length >= 2;
    if (!_hasCelebrated && wasShortEnough && isLongEnoughNow) {
      _hasCelebrated = true;
      setState(() => _mood = PakoMood.celebrate);
      _celebrateTimer = Timer(_celebrateDuration, () {
        if (mounted) setState(() => _mood = PakoMood.idle);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _celebrateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // docs/SCREENS.md A2: Pako shrinks to 48 px once the keyboard is up,
    // so it never fights the field/avatar/color-picker for space.
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final pakoSize = keyboardOpen ? 48.0 : 64.0;

    return StepTransition(
      child: OnboardingScaffold(
        body: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              // The content can be shorter than the viewport (no
              // keyboard) or taller (keyboard up) — this sizes to at
              // least the available height without forcing a second,
              // nested scrollable inside it.
              hasScrollBody: false,
              child: NameStepForm(
                mood: _mood,
                pakoSize: pakoSize,
                name: widget.name,
                initialColor: widget.initialColor,
                controller: _controller,
                onNameChanged: widget.onNameChanged,
                onColorChanged: widget.onColorChanged,
              ),
            ),
          ],
        ),
        footer: PrimaryButton(
          label: 'Next',
          isDisabled: !widget.isValid,
          onTap: widget.isValid ? widget.onNext : null,
        ),
      ),
    );
  }
}
