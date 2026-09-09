import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_buttons.dart';
import 'pako_state.dart';

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

/// Shared icon + title + body + optional CTA layout for [EmptyStateView]
/// and [ErrorStateView] — see `docs/SCREENS.md` G ("Empty: outline icon,
/// one-line headline, one-line body, optional CTA. Error: same layout
/// with 'Retry'."). Concrete screens use Pako asleep for this icon (e.g.
/// B4, B2's "No results").
class _StateLayout extends StatelessWidget {
  const _StateLayout({
    required this.title,
    required this.body,
    this.ctaLabel,
    this.onCtaTap,
  });

  final String title;
  final String body;
  final String? ctaLabel;
  final VoidCallback? onCtaTap;

  @override
  Widget build(BuildContext context) {
    final cta = ctaLabel;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const PakoState(mood: PakoMood.asleep),
          const SizedBox(height: AppSpacing.lg),
          Text(title, style: AppTextStyles.h2, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text(
            body,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
            textAlign: TextAlign.center,
          ),
          if (cta != null) ...[
            const SizedBox(height: AppSpacing.lg),
            SecondaryButton(label: cta, onTap: onCtaTap, fullWidth: false),
          ],
        ],
      ),
    );
  }
}

/// Empty state: Pako asleep, a headline, a body line, and an optional CTA.
///
/// Pure presentation — no feature dependency, everything comes in by
/// parameter.
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.title,
    required this.body,
    this.ctaLabel,
    this.onCtaTap,
  });

  final String title;
  final String body;
  final String? ctaLabel;
  final VoidCallback? onCtaTap;

  @override
  Widget build(BuildContext context) {
    return _StateLayout(
      title: title,
      body: body,
      ctaLabel: ctaLabel,
      onCtaTap: onCtaTap,
    );
  }
}

/// Error state: the same layout as [EmptyStateView], always with a
/// "Retry" button — copy is fixed per `docs/SCREENS.md` G.
///
/// Pure presentation — no feature dependency, everything comes in by
/// parameter.
class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    super.key,
    required this.title,
    required this.body,
    this.onRetry,
  });

  final String title;
  final String body;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return _StateLayout(
      title: title,
      body: body,
      ctaLabel: 'Retry',
      onCtaTap: onRetry,
    );
  }
}

/// Persistent thin "Offline" banner.
///
/// Source of truth: `docs/SCREENS.md` G ("Offline: persistent top banner
/// 'Offline' + screens use local data when available."). Uses a neutral
/// treatment (`surfaceRaised2` / `inkMuted`) rather than `danger` — being
/// offline isn't an error here, the app keeps working from cached data.
///
/// Pure presentation — no feature dependency, everything comes in by
/// parameter (there are none: the copy is fixed by the doc above).
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceRaised2,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          'Offline',
          textAlign: TextAlign.center,
          style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
        ),
      ),
    );
  }
}
