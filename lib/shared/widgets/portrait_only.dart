import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Keeps the app upright while [child] is on screen, then gives the previous
/// freedom back. For screens drawn for a tall phone (Surprise me's deck: a
/// stack of portrait cards, with bubbles at the edges) that make no sense
/// sideways.
class PortraitOnly extends StatefulWidget {
  const PortraitOnly({super.key, required this.child});

  final Widget child;

  @override
  State<PortraitOnly> createState() => _PortraitOnlyState();
}

class _PortraitOnlyState extends State<PortraitOnly> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    // An empty list means "no preference": every orientation the platform allows.
    SystemChrome.setPreferredOrientations(const []);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
