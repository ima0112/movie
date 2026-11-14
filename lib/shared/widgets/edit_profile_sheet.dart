import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/cubits/user_profile_cubit.dart';
import '../../core/domain/entities/user_profile.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/l10n_extension.dart';
import 'app_buttons.dart';
import 'overline_label.dart';
import 'profile_avatar.dart';
import 'profile_color_picker.dart';
import 'profile_name_field.dart';

/// H10 (Edit profile) — `docs/SCREENS.md` H10: "Name and initial color (6).
/// Same controls as onboarding step 1": [ProfileAvatar] (the live preview),
/// [ProfileNameField] and [ProfileColorPicker], shared with that step.
///
/// Opens from B5's header ([YouHeader]'s `onEditProfile`). Reads/writes
/// the global [UserProfileCubit] directly via `context.read` rather
/// than taking a repository or the current profile by constructor —
/// it's a genuinely global Cubit (CLAUDE.md rule 10), already in scope
/// everywhere from `app/app.dart`, so there's nothing to thread through.
///
/// "Save" (onboarding's own button says "Continue" — this is "Save" instead,
/// matching every other edit sheet in the app, e.g. H2's) stays disabled under
/// 2 characters, same as that step's button.
class EditProfileSheet extends StatefulWidget {
  const EditProfileSheet({super.key});

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late final TextEditingController _nameController;
  int? _selectedColor;

  static const double _avatarSize = 72;

  @override
  void initState() {
    super.initState();
    final current = context.read<UserProfileCubit>().state;
    _nameController = TextEditingController(text: current?.displayName ?? '');
    // The first color (amber) is preselected, as in onboarding.
    _selectedColor =
        current?.initialColor ?? AppColors.profileColors.first.toARGB32();
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
    final l10n = context.l10n;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The live preview: the initial (or a person icon while the name is
            // empty) over the picked color.
            Center(
              child: ProfileAvatar(
                displayName: _nameController.text,
                initialColor: _selectedColor,
                size: _avatarSize,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.editProfileSheetTitle,
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.onboardingNameBody,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
            ),
            const SizedBox(height: AppSpacing.xl),
            OverlineLabel(l10n.profileNameLabel),
            const SizedBox(height: AppSpacing.sm),
            ProfileNameField(
              controller: _nameController,
              hint: l10n.onboardingNameHint,
              autofocus: true,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.lg),
            OverlineLabel(l10n.profileColorLabel),
            const SizedBox(height: AppSpacing.sm),
            ProfileColorPicker(
              selected: _selectedColor,
              onChanged: (color) => setState(() => _selectedColor = color),
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: l10n.commonSave,
              onTap: _save,
              isDisabled: !_canSave,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextLinkButton(
              label: l10n.commonCancel,
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
