import 'package:flutter/material.dart';

import '../../../core/domain/entities/person.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../profile_image.dart';

/// One person in [FullCastSheet]'s grid: a 4:5 rounded portrait, the name
/// (semibold) and the character or job underneath. Its width comes from
/// the parent; it sizes its own height, so large text never overflows.
class FullCastPersonTile extends StatelessWidget {
  const FullCastPersonTile({
    super.key,
    required this.person,
    this.role,
    required this.onTap,
  });

  final Person person;
  final String? role;
  final VoidCallback onTap;

  static const double _portraitAspect = 4 / 5;

  @override
  Widget build(BuildContext context) {
    final role = this.role;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: _portraitAspect,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: ProfileImage(
                profilePath: person.profilePath,
                name: person.name,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            person.name,
            style: AppTextStyles.bodySmStrong,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (role != null && role.isNotEmpty)
            Text(
              role,
              style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}
