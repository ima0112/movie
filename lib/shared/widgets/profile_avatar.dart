import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_text_styles.dart';

/// A profile's circular avatar: [displayName]'s first letter over
/// [initialColor], or — while there is no name yet (`displayName` null or
/// empty) — a person icon over the same color (`surfaceRaised` when no color
/// has been picked either). The mascot is gone, so the empty state is just
/// that icon.
///
/// Takes the raw fields rather than a `UserProfile`, so it also works as a live
/// preview for a draft that isn't a valid profile yet — onboarding's name step
/// and H10 need exactly that while the user is still typing. A large [size]
/// (from [largeFrom]) draws the initial in the display type.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.displayName,
    required this.initialColor,
    this.size = 36,
  });

  final String? displayName;
  final int? initialColor;
  final double size;

  /// From this size on the initial uses the display type, not `h3`.
  static const double largeFrom = 72;
  static const double _iconRatio = 0.5;

  @override
  Widget build(BuildContext context) {
    final name = displayName;
    final color = initialColor;
    final background = color == null ? AppColors.surfaceRaised : Color(color);
    if (name == null || name.isEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: background,
        child: Icon(
          AppIcons.user,
          size: size * _iconRatio,
          color: color == null ? AppColors.inkMuted : AppColors.onAccent,
        ),
      );
    }
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: background,
      child: Text(
        name[0].toUpperCase(),
        style: (size >= largeFrom ? AppTextStyles.display : AppTextStyles.h3)
            .copyWith(color: AppColors.onAccent),
      ),
    );
  }
}
