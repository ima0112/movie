import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../l10n/l10n_extension.dart';
import 'scrim_back_button.dart';

/// D1/D2's Share button: the same translucent 40 px circle as
/// [ScrimBackButton], top right, with the share icon. Drop it into a `Stack`
/// like the back button — [Align] and [SafeArea] keep it clear of the
/// notch. Its accessibility label is "Share"; [onTap] does the sharing.
class ScrimShareButton extends StatelessWidget {
  const ScrimShareButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Semantics(
            button: true,
            excludeSemantics: true,
            label: context.l10n.mediaDetailShare,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: ScrimBackButton.diameter,
                height: ScrimBackButton.diameter,
                decoration: const BoxDecoration(
                  color: ScrimBackButton.scrim,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  AppIcons.share,
                  color: AppColors.ink,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
