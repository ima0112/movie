import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/cubits/user_profile_cubit.dart';
import '../../core/domain/entities/user_profile.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_buttons.dart';
import 'pako_state.dart';
import 'profile_avatar.dart';
import 'profile_color_picker.dart';

/// H10 (Edit profile) — `docs/SCREENS.md` H10: "Name and initial color
/// (4). Same controls as onboarding step 1." Onboarding (A2) doesn't
/// exist yet, so [ProfileAvatar]/[ProfileColorPicker] (the reusable
/// pieces of "the same controls") were built for this sheet first —
/// onboarding step 1 should reuse them once it exists, not duplicate.
///
/// Opens from B5's header ([YouHeader]'s `onEditProfile`). Reads/writes
/// the global [UserProfileCubit] directly via `context.read` rather
/// than taking a repository or the current profile by constructor —
/// it's a genuinely global Cubit (CLAUDE.md rule 10), already in scope
/// everywhere from `app/app.dart`, so there's nothing to thread through.
///
/// Per A2 step 1: typing reveals the avatar preview and color picker
/// (hidden while the name is empty); "Save" (onboarding's own button
/// says "Next" — this is "Save" instead, matching every other edit
/// sheet in the app, e.g. H2's) stays disabled under 2 characters, same
/// as that step's "Next".
class EditProfileSheet extends StatefulWidget {
  const EditProfileSheet({super.key});

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late final TextEditingController _nameController;
  int? _selectedColor;

  @override
  void initState() {
    super.initState();
    final current = context.read<UserProfileCubit>().state;
    _nameController = TextEditingController(text: current?.displayName ?? '');
    _selectedColor = current?.initialColor;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _canSave => _nameController.text.trim().length >= 2;

  void _save() {
    // No color ever picked (e.g. saved via a paste that skipped
    // onChanged) — default to the first swatch rather than block Save.
    final color = _selectedColor ?? AppColors.profileColors.first.toARGB32();
    context.read<UserProfileCubit>().save(
      UserProfile(
        displayName: _nameController.text.trim(),
        initialColor: color,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final name = _nameController.text;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: PakoState(mood: PakoMood.idle, size: 56)),
            const SizedBox(height: AppSpacing.lg),
            Text('Edit profile', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.sm),
            Text(
              "That's what I'll call you, and how others will see you in "
              'rooms.',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
            ),
            const SizedBox(height: AppSpacing.xl),
            TextField(
              controller: _nameController,
              autofocus: true,
              style: AppTextStyles.body,
              decoration: const InputDecoration(hintText: 'Your name'),
              onChanged: (value) => setState(() {
                if (value.trim().isNotEmpty && _selectedColor == null) {
                  _selectedColor = AppColors.profileColors.first.toARGB32();
                }
              }),
            ),
            if (name.trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  ProfileAvatar(
                    displayName: name,
                    initialColor: _selectedColor,
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: ProfileColorPicker(
                      selected: _selectedColor,
                      onChanged: (color) =>
                          setState(() => _selectedColor = color),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(label: 'Save', onTap: _save, isDisabled: !_canSave),
          ],
        ),
      ),
    );
  }
}
