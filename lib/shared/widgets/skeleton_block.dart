import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// A skeleton placeholder block with a subtle shimmer sweep.
///
/// Source of truth: `docs/DESIGN_SYSTEM.md` section 5.8 ("skeleton (shimmer
/// sutil)") and `docs/SCREENS.md` G ("Skeleton: version for carousel,
/// grid, row list, detail.") — this is the one primitive block; screens
/// compose it into whatever skeleton shape they need.
///
/// Pure presentation — no feature dependency, everything comes in by
/// parameter. Respects the system's "reduce motion" setting (see
/// `docs/DESIGN_SYSTEM.md` section 7): the shimmer sweep freezes into a
/// flat block when it's on.
class SkeletonBlock extends StatefulWidget {
  const SkeletonBlock({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  final double width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  State<SkeletonBlock> createState() => _SkeletonBlockState();
}

class _SkeletonBlockState extends State<SkeletonBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // React live to the system's "reduce motion" setting, per
    // docs/DESIGN_SYSTEM.md section 7.
    if (MediaQuery.of(context).disableAnimations) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius =
        widget.borderRadius ?? BorderRadius.circular(AppSpacing.radiusMd);
    final block = DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: radius,
      ),
      child: SizedBox(width: widget.width, height: widget.height),
    );

    if (MediaQuery.of(context).disableAnimations) {
      return block;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: const [
                AppColors.surfaceRaised,
                AppColors.surfaceRaised2,
                AppColors.surfaceRaised,
              ],
              stops: const [0.35, 0.5, 0.65],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              transform: _SlidingGradientTransform(_controller.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: block,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform(this.slidePercent);

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    // Sweeps the highlight from off-screen left to off-screen right.
    return Matrix4.translationValues(
      bounds.width * (slidePercent * 3 - 1.5),
      0,
      0,
    );
  }
}
