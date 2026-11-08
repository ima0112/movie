import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/cubits/user_profile_cubit.dart';
import '../../../../core/domain/entities/user_profile.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/pako_state.dart';

const double _avatarSize = 36;

/// B5 ("You")'s header row: the user's initial + name, or Pako's
/// silhouette + "Tap to set your name" if no profile has been saved yet.
///
/// Source of truth: `docs/SCREENS.md` B5 — "Header: initial in a circle
/// with the chosen color (36 px), 'Hi, Daniel' 24/500 (no name: Pako's
/// silhouette in the circle, 'Hi' and subtitle 'Tap to set your name');
/// tapping the header edits name and color in a sheet (H10). Gear icon
/// top right → C6." Both destinations (H10, C6) don't exist yet, so
/// they're plain callbacks the not-yet-built `you_screen.dart` will
/// eventually wire to a sheet/route.
///
/// Only the initial+name portion subscribes to the global
/// [UserProfileCubit] — the gear icon is static and must never sit
/// inside that `BlocBuilder` (CLAUDE.md rule 9).
///
/// SCREENS.md's "24/500" for the name doesn't match any
/// [AppTextStyles] token exactly (the nearest are `h1` 26/600 and `h2`
/// 20/600); this uses `h2` as the closest fit rather than hardcoding a
/// one-off size (rule 4).
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
                  _Avatar(profile: profile),
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

class _Avatar extends StatelessWidget {
  const _Avatar({required this.profile});

  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    final profile = this.profile;
    if (profile == null) {
      // "Pako's silhouette" — PakoMood.off is the mascot's outline/no-face
      // rendering (see docs/DECISIONS.md section 9: "Off (outline, no
      // face) = logo").
      return const CircleAvatar(
        radius: _avatarSize / 2,
        backgroundColor: AppColors.surfaceRaised,
        child: PakoState(mood: PakoMood.off, size: _avatarSize * 0.7),
      );
    }
    final initial = profile.displayName.isEmpty
        ? ''
        : profile.displayName[0].toUpperCase();
    return CircleAvatar(
      radius: _avatarSize / 2,
      backgroundColor: Color(profile.initialColor),
      child: Text(
        initial,
        style: AppTextStyles.h3.copyWith(color: AppColors.onAccent),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.profile});

  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    final profile = this.profile;
    if (profile == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Hi', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Tap to set your name',
            style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
          ),
        ],
      );
    }
    return Text(
      'Hi, ${profile.displayName}',
      style: AppTextStyles.h2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
