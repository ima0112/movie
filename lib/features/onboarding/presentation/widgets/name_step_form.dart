import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/pako_state.dart';
import '../../../../shared/widgets/profile_avatar.dart';
import '../../../../shared/widgets/profile_color_picker.dart';

/// `NameStep`'s own scrollable content — split out so that file stays
/// under rule 11's 150-line limit once it gained `CustomScrollView` +
/// keyboard-aware Pako sizing.
class NameStepForm extends StatelessWidget {
  const NameStepForm({
    super.key,
    required this.mood,
    required this.pakoSize,
    required this.name,
    required this.initialColor,
    required this.controller,
    required this.onNameChanged,
    required this.onColorChanged,
  });

  final PakoMood mood;
  final double pakoSize;
  final String name;
  final int? initialColor;
  final TextEditingController controller;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<int> onColorChanged;

  @override
  Widget build(BuildContext context) {
    final hasName = name.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: AppSpacing.lg),
        PakoState(mood: mood, size: pakoSize),
        const SizedBox(height: AppSpacing.lg),
        Text("What's your name?", style: AppTextStyles.h1),
        const SizedBox(height: AppSpacing.sm),
        Text(
          "That's what I'll call you, and how others will see you in "
          'rooms.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
        ),
        const SizedBox(height: AppSpacing.xxl),
        TextField(
          controller: controller,
          autofocus: true,
          style: AppTextStyles.body,
          decoration: const InputDecoration(hintText: 'Your name'),
          onChanged: onNameChanged,
        ),
        if (hasName) ...[
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              ProfileAvatar(displayName: name, initialColor: initialColor),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: ProfileColorPicker(
                  selected: initialColor,
                  onChanged: onColorChanged,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
