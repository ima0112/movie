import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'pako_state.dart';

/// A profile's circular avatar: [displayName]'s first letter over
/// [initialColor], or Pako's silhouette (`PakoMood.off` — "outline, no
/// face" per `docs/DECISIONS.md` section 9) over `surfaceRaised` when
/// there's no name yet (`displayName` null or empty).
///
/// Takes the raw fields rather than a `UserProfile`, so it also works as
/// a live preview for a draft that isn't a valid [UserProfile] yet — H10
/// ([EditProfileSheet]) needs exactly that while the user is still
/// typing a name before picking a color. [YouHeader] is the other
/// caller, passing an already-saved profile's fields.
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

  @override
  Widget build(BuildContext context) {
    final name = displayName;
    if (name == null || name.isEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: AppColors.surfaceRaised,
        child: PakoState(mood: PakoMood.off, size: size * 0.7),
      );
    }
    final color = initialColor;
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: color == null ? AppColors.surfaceRaised : Color(color),
      child: Text(
        name[0].toUpperCase(),
        style: AppTextStyles.h3.copyWith(color: AppColors.onAccent),
      ),
    );
  }
}
