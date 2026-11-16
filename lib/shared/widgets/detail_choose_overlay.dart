import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../l10n/l10n_extension.dart';
import 'app_buttons.dart';

/// What a title's detail screen is asked to offer when it is opened from
/// Surprise me's deck: a fixed "Choose this" button that does what the double
/// tap does ([onChoose]). Passed as the route's `extra`
/// (`pushMediaDetail(key, extra: ...)`); the detail screens themselves know
/// nothing about it.
class DetailChooseAction {
  const DetailChooseAction({required this.onChoose});

  final Future<void> Function() onChoose;
}

/// Puts [child] — a detail screen — under a fixed bottom "Choose this" button
/// when [action] is given; otherwise just [child]. Choosing runs the action,
/// then leaves the detail (back to the deck, which by then shows the closing
/// screen).
class DetailChooseOverlay extends StatelessWidget {
  const DetailChooseOverlay({super.key, required this.child, this.action});

  final Widget child;
  final DetailChooseAction? action;

  /// The fade behind the button, so the content scrolls under it.
  static const double _fadeHeight = 120;

  @override
  Widget build(BuildContext context) {
    final action = this.action;
    if (action == null) return child;
    return Stack(
      children: [
        child,
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.surface.withValues(alpha: 0),
                  AppColors.surface.withValues(alpha: 0.96),
                ],
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenMargin,
                  _fadeHeight - AppSpacing.xxxl * 2,
                  AppSpacing.screenMargin,
                  AppSpacing.lg,
                ),
                child: PrimaryButton(
                  label: context.l10n.surpriseChooseThis,
                  icon: AppIcons.check,
                  onTap: () async {
                    HapticFeedback.mediumImpact();
                    final router = GoRouter.of(context);
                    await action.onChoose();
                    if (router.canPop()) router.pop();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
