import 'package:flutter/material.dart';

import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/person.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/genre_localization.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/media_type_localization.dart';
import '../../../../l10n/number_format_extension.dart';
import '../../../../shared/widgets/profile_image.dart';
import 'search_result_tile.dart';

/// A title's result row: its poster; the title; "year · Movie/TV Show · genre"
/// (one genre, the first, which is what identifies it best); and the ★ rating
/// on a third line (nothing while TMDB has no score).
class MediaResultRow extends StatelessWidget {
  const MediaResultRow({super.key, required this.item, required this.onTap});

  final MediaItem item;
  final VoidCallback onTap;

  static const double _star = 12;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final url = item.posterUrl;
    return SearchResultTile(
      onTap: onTap,
      title: item.title,
      subtitle: subtitleOf(item, l10n),
      third: item.voteAverage > 0
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  AppIcons.starFill,
                  size: _star,
                  color: AppColors.accent,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  item.voteAverage.localizedRating(l10n),
                  style: AppTextStyles.bodySmStrong,
                ),
              ],
            )
          : null,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: url == null
            ? const ColoredBox(color: AppColors.surfaceRaised2)
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const ColoredBox(color: AppColors.surfaceRaised2),
              ),
      ),
    );
  }

  /// "2018 · TV Show · Drama": the year (when known), the kind, and the first
  /// genre (when it has one).
  static String subtitleOf(MediaItem item, AppLocalizations l10n) {
    final year = item.releaseDate?.year;
    return [
      ?(year == null ? null : '$year'),
      item.type.localizedSingular(l10n),
      ?(item.genres.isEmpty ? null : item.genres.first.localizedName(l10n)),
    ].join(' · ');
  }
}

/// A person's result row: a round photo (their initial when there is none), the
/// name and "Department · Person".
class PersonResultRow extends StatelessWidget {
  const PersonResultRow({super.key, required this.person, required this.onTap});

  final Person person;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final department = person.knownForDepartment;
    return SearchResultTile(
      onTap: onTap,
      title: person.name,
      subtitle: department == null || department.isEmpty
          ? l10n.explorePersonLabel
          : l10n.explorePersonMetadata(department),
      // The same slot as a poster, so rows line up; the photo is round.
      leading: Center(
        child: ClipOval(
          child: SizedBox(
            width: SearchResultTile.leadingWidth,
            height: SearchResultTile.leadingWidth,
            child: ProfileImage(
              profilePath: person.profilePath,
              name: person.name,
            ),
          ),
        ),
      ),
    );
  }
}
