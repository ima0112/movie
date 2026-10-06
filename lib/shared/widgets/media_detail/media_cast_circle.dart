import 'package:flutter/material.dart';

import '../../../core/domain/entities/person.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../profile_image.dart';

/// One [MediaCastRow] circle: a 64 px avatar, name, and character
/// (`docs/SCREENS.md` D1, reused unchanged by D2). In its own file per
/// rule 11: `media_cast_row.dart` was over the 150-line target on its
/// own.
///
/// Uses [ProfileImage] — same widget `person_detail_header.dart` and
/// `full_cast_sheet.dart` use — rather than painting `profilePath`
/// straight into `Image.network`, which this file used to do: TMDB's
/// `profile_path` is a raw path (e.g. `/abc123.jpg`), not a full URL, so
/// that request always failed and a photo never actually showed.
class MediaCastCircle extends StatelessWidget {
  const MediaCastCircle({
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
                child: ProfileImage(
                  profilePath: member.person.profilePath,
                  name: member.person.name,
                ),
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
