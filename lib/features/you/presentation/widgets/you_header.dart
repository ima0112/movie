import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/cubits/user_profile_cubit.dart';
import '../../../../core/domain/entities/user_profile.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/profile_avatar.dart';

const double _avatarSize = 48;
const double _badgeSize = 20;
const double _badgeIconSize = 11;

/// B5 ("You")'s header row: the user's initial + name, or Pako's
/// silhouette + "Tap to set your name" if no profile has been saved yet.
///
/// Source of truth: `docs/SCREENS.md` B5 — "Header: initial in a circle
/// with the chosen color (36 px), 'Hi, Daniel' 24/500 (no name: Pako's
/// silhouette in the circle, 'Hi' and subtitle 'Tap to set your name');
/// tapping the header edits name and color in a sheet (H10). Gear icon
/// top right → C6." [onEditProfile] opens H10 (`EditProfileSheet`,
/// `shared/widgets/edit_profile_sheet.dart`); C6 doesn't exist yet, so
/// [onOpenSettings] is a plain callback `you_screen.dart` doesn't wire
/// to anything real yet.
///
/// Only the initial+name portion subscribes to the global
/// [UserProfileCubit] — the gear icon is static and must never sit
/// inside that `BlocBuilder` (CLAUDE.md rule 9).
///
/// The name uses `h1` (26/600), the "Tú · Perfil" design's size, with
/// a 48 px avatar carrying a small edit badge.
class YouHeader extends StatelessWidget {
  const YouHeader({
    super.key,
    required this.onEditProfile,
    required this.onOpenSettings,
  });

  /// → H10 ("Edit profile").
  final VoidCallback onEditProfile;

  /// → C6 ("Settings").
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onEditProfile,
            child: BlocBuilder<UserProfileCubit, UserProfile?>(
              builder: (context, profile) => Row(
                children: [
                  _AvatarWithEditBadge(profile: profile),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: _Greeting(profile: profile)),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: onOpenSettings,
          icon: const Icon(AppIcons.settings, color: AppColors.ink),
        ),
      ],
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.profile});

  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    final profile = this.profile;
    final l10n = context.l10n;
    if (profile == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.youHeaderGreetingNoProfile, style: AppTextStyles.h1),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.youHeaderTapToSetName,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
          ),
        ],
      );
    }
    return Text(
      l10n.youHeaderGreetingWithName(profile.displayName),
      style: AppTextStyles.h1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// The avatar with a small pencil badge, bottom right — signals that the
/// header opens the edit sheet (H10).
class _AvatarWithEditBadge extends StatelessWidget {
  const _AvatarWithEditBadge({required this.profile});

  final UserProfile? profile;

  static const double _badgeOffset = -4;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ProfileAvatar(
          displayName: profile?.displayName,
          initialColor: profile?.initialColor,
          size: _avatarSize,
        ),
        Positioned(
          right: _badgeOffset,
          bottom: _badgeOffset,
          child: Container(
            width: _badgeSize,
            height: _badgeSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(color: AppColors.lineStrong),
            ),
            child: const Icon(
              AppIcons.edit,
              size: _badgeIconSize,
              color: AppColors.ink,
            ),
          ),
        ),
      ],
    );
  }
}
