import 'package:flutter/material.dart';

import '../../../core/domain/entities/genre.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/genre_localization.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../l10n/number_format_extension.dart';
import 'info_chip.dart';

/// The card under D1/D2's trailer button ("Detalle" design): the poster,
/// "year · genres" (each genre tappable → C1 with that genre), small info
/// chips (rating first, then [extraChips]), and the action toggles
/// ([actions]) at the bottom.
///
/// Pure presentation (CLAUDE.md rule 9) — the toggles' own Bloc/stream
/// subscriptions live in [actions], not here.
class MediaDetailInfoCard extends StatelessWidget {
  const MediaDetailInfoCard({
    super.key,
    required this.posterUrl,
    required this.metaPrefix,
    required this.genres,
    required this.voteAverage,
    required this.actions,
    this.extraChips = const [],
    this.onGenreTap,
  });

  /// The poster's full URL (`MediaItem.posterUrl`), or `null` for a flat
  /// placeholder.
  final String? posterUrl;

  /// The text before the genres — a year, or D2's "2008–2013 · 5 seasons…".
  final String metaPrefix;
  final List<Genre> genres;
  final double voteAverage;
  final List<String> extraChips;
  final void Function(Genre genre)? onGenreTap;
  final Widget actions;

  static const double _posterWidth = 100;
  static const double _posterHeight = 150;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: SizedBox(
              width: _posterWidth,
              height: _posterHeight,
              child: _Poster(url: posterUrl),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MetaLine(
                  prefix: metaPrefix,
                  genres: genres,
                  onGenreTap: onGenreTap,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs + 2,
                  runSpacing: AppSpacing.xs + 2,
                  children: [
                    InfoChip(
                      label: voteAverage.localizedRating(l10n),
                      icon: AppIcons.starFill,
                    ),
                    for (final chip in extraChips) InfoChip(label: chip),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                actions,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({
    required this.prefix,
    required this.genres,
    required this.onGenreTap,
  });

  final String prefix;
  final List<Genre> genres;
  final void Function(Genre genre)? onGenreTap;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted);
    return Wrap(
      children: [
        if (prefix.isNotEmpty) Text(prefix, style: style),
        for (var i = 0; i < genres.length; i++) ...[
          if (i > 0 || prefix.isNotEmpty) Text(' · ', style: style),
          GestureDetector(
            onTap: () => onGenreTap?.call(genres[i]),
            behavior: HitTestBehavior.opaque,
            child: Text(genres[i].localizedName(context.l10n), style: style),
          ),
        ],
      ],
    );
  }
}

class _Poster extends StatelessWidget {
  const _Poster({required this.url});

  final String? url;

  static const _placeholder = ColoredBox(color: AppColors.surfaceRaised2);

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    if (url == null) return _placeholder;
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _placeholder,
    );
  }
}
