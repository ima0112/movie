import 'package:flutter/material.dart';

import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../l10n/l10n_extension.dart';
import '../../../../../shared/widgets/app_buttons.dart';

/// The deck's visible controls for people who can't (or don't want to) use the
/// gestures — shown when a screen reader or switch access is on: Save, Choose
/// this and Next, each a normal button with a label. They do exactly what
/// swiping left (save, staying on the card), double-tapping and swiping right do.
///
/// Pure presentation — everything comes in by parameter.
class SurpriseAccessibleControls extends StatelessWidget {
  const SurpriseAccessibleControls({
    super.key,
    required this.onSave,
    required this.onChoose,
    required this.onNext,
    this.canNext = true,
  });

  final VoidCallback onSave;
  final VoidCallback onChoose;
  final VoidCallback onNext;

  /// False with a single card: there is nowhere to pass to.
  final bool canNext;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenMargin),
      child: Column(
        children: [
          PrimaryButton(
            label: l10n.surpriseChooseThis,
            icon: AppIcons.check,
            onTap: onChoose,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: l10n.surpriseControlSave,
                  onTap: onSave,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: SecondaryButton(
                  label: l10n.surpriseControlNext,
                  onTap: onNext,
                  isDisabled: !canNext,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
