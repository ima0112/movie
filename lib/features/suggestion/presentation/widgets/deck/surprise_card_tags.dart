import 'package:flutter/material.dart';

import '../../../../../core/domain/entities/media_type.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../l10n/l10n_extension.dart';

/// A Surprise-me card's row of tags: its affinity ("88 % for you", amber on a
/// dark amber tint) and the kind of title (icon + "Movie" or "Series").
class SurpriseCardTags extends StatelessWidget {
  const SurpriseCardTags({
    super.key,
    required this.affinityPercent,
    required this.mediaType,
  });

  final int affinityPercent;
  final MediaType mediaType;

  static const double _iconSize = 14;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isMovie = mediaType == MediaType.movie;
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: [
        _Pill(
          background: AppColors.accentSoft,
          child: Text(
            l10n.surpriseCardAffinity(affinityPercent),
            style: AppTextStyles.captionStrong.copyWith(
              color: AppColors.accent,
            ),
          ),
        ),
        _Pill(
          border: AppColors.lineStrong,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isMovie ? AppIcons.movie : AppIcons.tvShow,
                size: _iconSize,
                color: AppColors.ink,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                isMovie
                    ? l10n.mediaTypeMovieSingular
                    : l10n.mediaTypeTvShowSingular,
                style: AppTextStyles.captionStrong,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.child, this.background, this.border});

  final Widget child;
  final Color? background;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: border == null ? null : Border.all(color: border!),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: child,
      ),
    );
  }
}
