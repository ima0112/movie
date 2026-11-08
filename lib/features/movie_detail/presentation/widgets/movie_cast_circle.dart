import 'package:flutter/material.dart';

import '../../../../core/domain/entities/person.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// One [MovieCastRow] circle: a 64 px avatar, name, and character
/// (SCREENS.md D1). In its own file per rule 11: `movie_cast_row.dart` was
/// over the 150-line target on its own.
class MovieCastCircle extends StatelessWidget {
  const MovieCastCircle({
    super.key,
    required this.member,
    required this.size,
    required this.onTap,
  });

  final CastMember member;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        child: Column(
          children: [
            ClipOval(
              child: SizedBox(
                width: size,
                height: size,
                child: _Avatar(profilePath: member.person.profilePath),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              member.person.name,
              style: AppTextStyles.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            Text(
              member.character,
              style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.profilePath});

  final String? profilePath;

  @override
  Widget build(BuildContext context) {
    final path = profilePath;
    if (path == null) return const ColoredBox(color: AppColors.surfaceRaised2);
    return Image.network(
      path,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const ColoredBox(color: AppColors.surfaceRaised2),
    );
  }
}
