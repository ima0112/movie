import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// The name field of a profile — onboarding's name step and "Edit profile"
/// (H10) share it: a `surfaceRaised` pill-cornered field with an amber hairline
/// (the full amber while focused), the hint ("Your name") and a `0/20` counter
/// inside at the end. It holds at most [maxLength] characters.
///
/// Pure presentation: the caller owns the [controller] and reacts to
/// [onChanged].
class ProfileNameField extends StatelessWidget {
  const ProfileNameField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.autofocus = false,
    this.focusNode,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final bool autofocus;
  final FocusNode? focusNode;

  /// The name's longest length (A2 / H10: 2–20 characters).
  static const int maxLength = 20;

  static const double _focusedWidth = 1.5;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(BorderSide side) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      borderSide: side,
    );
    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      onChanged: onChanged,
      style: AppTextStyles.body,
      cursorColor: AppColors.accent,
      textInputAction: TextInputAction.done,
      inputFormatters: [LengthLimitingTextInputFormatter(maxLength)],
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.inkMuted),
        filled: true,
        fillColor: AppColors.surfaceRaised,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        enabledBorder: border(const BorderSide(color: AppColors.accentLine)),
        border: border(const BorderSide(color: AppColors.accentLine)),
        focusedBorder: border(
          const BorderSide(color: AppColors.accent, width: _focusedWidth),
        ),
        suffixIconConstraints: const BoxConstraints(),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: AppSpacing.lg),
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) => Text(
              '${value.text.characters.length}/$maxLength',
              style: AppTextStyles.captionStrong.copyWith(
                color: AppColors.inkMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
