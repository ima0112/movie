import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';

/// Shared "screen" shell for A2's own steps — CLAUDE.md rule 14: every
/// screen sits on a `Scaffold` with a real `SafeArea` (top and bottom,
/// never a fixed pixel padding), `AppSpacing.xl` horizontal margin, an
/// optional "Step X of 3" / "Skip" header, a scrollable [body], and a
/// fixed footer holding the main button with a 24 px fade over the
/// content above it.
///
/// [body] decides its own scroll mechanism (a `GridView` is already
/// scrollable; `NameStep` wraps its content in `CustomScrollView` +
/// `SliverFillRemaining` instead) — this widget only constrains and
/// fades it, never imposes one.
class OnboardingScaffold extends StatelessWidget {
  const OnboardingScaffold({
    super.key,
    this.stepLabel,
    this.onSkip,
    required this.body,
    required this.footer,
  });

  final String? stepLabel;
  final VoidCallback? onSkip;
  final Widget body;
  final Widget footer;

  static const double _fadeHeight = 24;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            children: [
              if (stepLabel != null) ...[
                const SizedBox(height: AppSpacing.lg),
                _Header(stepLabel: stepLabel!, onSkip: onSkip),
              ],
              Expanded(
                child: Stack(
                  children: [
                    body,
                    const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: _fadeHeight,
                      child: IgnorePointer(child: _FadeOverlay()),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: footer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.stepLabel, required this.onSkip});

  final String stepLabel;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          stepLabel,
          style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
        ),
        if (onSkip != null)
          GestureDetector(
            onTap: onSkip,
            child: Text(
              context.l10n.commonSkip,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
            ),
          ),
      ],
    );
  }
}

class _FadeOverlay extends StatelessWidget {
  const _FadeOverlay();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, AppColors.surface],
        ),
      ),
    );
  }
}
