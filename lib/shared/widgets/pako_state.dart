import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Pako's possible moods.
///
/// Mirrors the state machine planned for the `.riv` file (see
/// `docs/DECISIONS.md` section 9): `powerOn`/off, `mood`
/// (neutral/searching/celebrating/asleep), `yearSlider`, `idle`.
enum PakoMood { off, idle, asleep, celebrate, search }

const Map<PakoMood, String> _pakoAssets = {
  PakoMood.off: 'assets/icons/pako/pako_off.svg',
  PakoMood.idle: 'assets/icons/pako/pako_idle.svg',
  PakoMood.asleep: 'assets/icons/pako/pako_asleep.svg',
  // No dedicated art yet — fall back to the idle SVG.
  PakoMood.celebrate: 'assets/icons/pako/pako_idle.svg',
  PakoMood.search: 'assets/icons/pako/pako_idle.svg',
};

// TODO(rive): replace with a RiveAnimation driving a state machine
// (powerOn, mood, yearSlider, idle) once the runtime is integrated.
/// Renders Pako, PakoTV's mascot, as a static SVG placeholder for [mood].
class PakoState extends StatelessWidget {
  const PakoState({super.key, required this.mood, this.size = 100});

  final PakoMood mood;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      _pakoAssets[mood]!,
      width: size,
      height: size,
    );
  }
}
