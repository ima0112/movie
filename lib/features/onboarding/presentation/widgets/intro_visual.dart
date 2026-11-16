import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import 'intro_phone_frame.dart';
import 'intro_slide_spec.dart';

/// The picture of an intro slide: the phone ([IntroSlideSpec.mock] inside an
/// `IntroPhoneFrame`) with its callouts, **scaled to the room it is given**.
///
/// The picture ignores the user's text size (it is an illustration, scaled as
/// a whole). The composition is drawn at its design size ([naturalWidth] × [naturalHeight]:
/// the 250 px phone plus [overhang] px each side for the callouts that stick
/// out) and then scaled as one piece, from its top-centre, to
/// `min(width fits, height fits)` within [minScale]..[maxScale]. So a callout
/// never leaves the screen on a narrow phone, a short screen shows a smaller
/// phone instead of a cropped one, and a large screen a larger one.
///
/// The phone is **always at the top** of the room, centered, so two slides given
/// the same room put their phones at the very same place. Its bottom is cut off
/// by the room's bottom edge; [fade] is how far up from there it dissolves
/// (to transparent, over whatever is behind it).
class IntroVisual extends StatelessWidget {
  const IntroVisual({super.key, required this.spec});

  final IntroSlideSpec spec;

  /// How far the callouts stick out of the phone on each side (the same for
  /// every slide, so every slide's phone is the same size).
  static const double overhang = 58;

  static const double naturalWidth = IntroPhoneFrame.width + 2 * overhang;
  static const double topPadding = AppSpacing.xxl;
  static const double naturalHeight = IntroPhoneFrame.height + topPadding;

  /// The most of the phone worth showing: scaled down until this much of the
  /// composition fits the room's height.
  static const double visibleDesignHeight = 430;

  static const double minScale = 0.6;
  static const double maxScale = 1.25;

  /// The scale for a room of [width] × [height].
  static double scaleFor(double width, double height) => math
      .min(width / naturalWidth, height / visibleDesignHeight)
      .clamp(minScale, maxScale);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = scaleFor(constraints.maxWidth, constraints.maxHeight);
        return ClipRect(
          // Only the bottom is cut: the phone's amber glow spills above and
          // beside it.
          clipper: const _BottomOnlyClipper(),
          child: OverflowBox(
            alignment: Alignment.topCenter,
            minWidth: 0,
            minHeight: 0,
            maxWidth: naturalWidth,
            maxHeight: naturalHeight,
            // The picture is an illustration drawn at a fixed design size (and
            // scaled by us): its texts must not also follow the user's text
            // size, or the callouts' text would outgrow their circles.
            child: MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.noScaling),
              child: Transform.scale(
                scale: scale,
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: naturalWidth,
                  height: naturalHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: overhang,
                        top: topPadding,
                        child: IntroPhoneFrame(child: spec.mock),
                      ),
                      for (final badge in spec.badges)
                        Positioned(
                          left: overhang + badge.left,
                          top: topPadding + badge.top,
                          child: badge.child,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Clips only the bottom edge.
class _BottomOnlyClipper extends CustomClipper<Rect> {
  const _BottomOnlyClipper();

  static const double _spill = 1000;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(-_spill, -_spill, size.width + _spill, size.height);

  @override
  bool shouldReclip(_BottomOnlyClipper oldClipper) => false;
}
