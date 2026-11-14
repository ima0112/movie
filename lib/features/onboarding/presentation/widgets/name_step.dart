import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/overline_label.dart';
import '../../../../shared/widgets/profile_avatar.dart';
import '../../../../shared/widgets/profile_color_picker.dart';
import '../../../../shared/widgets/profile_name_field.dart';
import 'genre_step_headline.dart';
import 'onboarding_glow_background.dart';
import 'step_transition.dart';

/// The name step — `docs/SCREENS.md` A2: **required, no "Skip"**, and the first
/// thing after the welcome. A large live avatar (the typed name's initial, or a
/// person icon while the field is empty, over the picked color), the amber
/// "YOUR PROFILE" eyebrow, the headline with its one amber word, the body, the
/// shared name field (`NAME`, `0/20`) and the six colors (`COLOR`); on the warm
/// glow like the rest of the onboarding. The button is disabled until the name
/// has 2–20 characters.
///
/// Pure presentation (CLAUDE.md rule 9): name, color and validity come from
/// `OnboardingCubit` through `OnboardingNameStep`; this widget never reads the
/// Cubit. The same controls as "Edit profile" (H10).
class NameStep extends StatefulWidget {
  const NameStep({
    super.key,
    required this.name,
    required this.initialColor,
    required this.isValid,
    required this.onNameChanged,
    required this.onColorChanged,
    required this.onNext,
    this.footerTop,
  });

  final String name;
  final int? initialColor;
  final bool isValid;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<int> onColorChanged;
  final VoidCallback onNext;

  /// Something above the button (the pagination dots).
  final Widget? footerTop;

  static const double avatarSize = 112;

  @override
  State<NameStep> createState() => _NameStepState();
}

class _NameStepState extends State<NameStep> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.name,
  );

  @override
  void didUpdateWidget(NameStep old) {
    super.didUpdateWidget(old);
    // Keep the field in step with the Cubit's draft (coming back to this step).
    if (widget.name != _controller.text) {
      _controller.value = _controller.value.copyWith(
        text: widget.name,
        selection: TextSelection.collapsed(offset: widget.name.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return StepTransition(
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: OnboardingGlowBackground(
          child: SafeArea(
            child: Column(
              children: [
                // Scrolls (and centers when there is room): a small phone, the
                // keyboard or large text never overflow (CLAUDE.md rule 14).
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: ProfileAvatar(
                                displayName: widget.name.trim(),
                                initialColor: widget.initialColor,
                                size: NameStep.avatarSize,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            Text(
                              l10n.onboardingNameEyebrow.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: AppTextStyles.overline.copyWith(
                                color: AppColors.accent,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            GenreStepHeadline(
                              text: l10n.onboardingNameHeadline,
                              highlightWord: l10n.onboardingNameHighlight,
                              style: AppTextStyles.display,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              l10n.onboardingNameBody,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.inkMuted,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                            OverlineLabel(l10n.profileNameLabel),
                            const SizedBox(height: AppSpacing.sm),
                            ProfileNameField(
                              controller: _controller,
                              hint: l10n.onboardingNameHint,
                              autofocus: true,
                              onChanged: widget.onNameChanged,
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            OverlineLabel(l10n.profileColorLabel),
                            const SizedBox(height: AppSpacing.sm),
                            ProfileColorPicker(
                              selected: widget.initialColor,
                              onChanged: widget.onColorChanged,
                            ),
                            const SizedBox(height: AppSpacing.xl),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (widget.footerTop != null) widget.footerTop!,
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.xl,
                    AppSpacing.lg,
                  ),
                  child: AccentButton(
                    label: l10n.onboardingNameContinue,
                    isDisabled: !widget.isValid,
                    onTap: widget.isValid ? widget.onNext : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
