import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/domain/entities/media_type.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../l10n/l10n_extension.dart';
import '../../../../match_engine/domain/surprise_batch.dart';
import 'surprise_card_meta.dart';
import 'surprise_card_number.dart';
import 'surprise_card_platforms.dart';
import 'surprise_card_tags.dart';

/// One card of Surprise me's deck (`docs/SCREENS.md` E3): the title's poster
/// over the whole card with a dark fade up the lower third so the text reads,
/// the outlined card [number] in the top-left corner, then — at the bottom —
/// the affinity and type tags, the title, the year and duration (or years and
/// seasons) with the rating, the tagline in italics and where to watch it.
///
/// One widget for movies and series. A poster that is missing or won't load
/// leaves a neutral card with the number and the title: still usable. Text is
/// cut with ellipsis at large sizes — the detail screen has the rest.
///
/// Pure presentation — everything comes in by parameter.
class SurpriseSuggestionCard extends StatelessWidget {
  const SurpriseSuggestionCard({
    super.key,
    required this.suggestion,
    required this.number,
    required this.total,
    this.topAction,
  });

  final SurpriseSuggestion suggestion;

  /// 1-based position in the batch — the card's identity for the session.
  final int number;
  final int total;

  /// A control in the top-right corner (the Watch later button); it takes its
  /// own touches, so the card's tap and double tap don't fire under it.
  final Widget? topAction;

  /// How much of the card's height the dark fade covers.
  static const double _fadeHeightFactor = 0.7;
  static const List<double> _fadeStops = [0, 0.3, 0.6, 1];

  /// How much of the card's height the top veil covers.
  static const double _topVeilHeightFactor = 0.3;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final item = suggestion.item;
    final meta = surpriseMetaLine(suggestion.detail, l10n);
    final tagline = suggestion.detail.tagline;
    final locale = Localizations.localeOf(context).toString();
    final rating = item.voteAverage > 0
        ? NumberFormat('0.0', locale).format(item.voteAverage)
        : null;

    final platformsPhrase = suggestion.platforms.isEmpty
        ? ''
        : ', ${l10n.surpriseCardPlatforms(suggestion.platforms.length)}';
    final label = l10n.surpriseCardSemantics(
      number,
      total,
      item.title,
      item.type == MediaType.movie
          ? l10n.mediaTypeMovieSingular
          : l10n.mediaTypeTvShowSingular,
      suggestion.affinityPercent,
      platformsPhrase,
    );

    return Semantics(
      container: true,
      label: label,
      child: ExcludeSemantics(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised2,
              border: Border.all(color: AppColors.lineStrong),
              borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _Poster(url: item.posterUrl),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: _fadeHeightFactor,
                    widthFactor: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          // Dark early: the tags and the title sit in the
                          // upper half of this band, over any poster.
                          stops: _fadeStops,
                          colors: [
                            AppColors.surface.withValues(alpha: 0),
                            AppColors.surface.withValues(alpha: 0.72),
                            AppColors.surface.withValues(alpha: 0.94),
                            AppColors.surface.withValues(alpha: 0.97),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // A soft veil behind the number so its outline reads on a
                // bright poster.
                Align(
                  alignment: Alignment.topCenter,
                  child: FractionallySizedBox(
                    heightFactor: _topVeilHeightFactor,
                    widthFactor: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.surface.withValues(alpha: 0.55),
                            AppColors.surface.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: -SurpriseCardNumber.overhang,
                  top: -SurpriseCardNumber.overhang,
                  child: SurpriseCardNumber(number: number),
                ),
                if (topAction != null)
                  Positioned(
                    top: AppSpacing.md,
                    right: AppSpacing.md,
                    child: topAction!,
                  ),
                Positioned(
                  left: AppSpacing.xl,
                  right: AppSpacing.xl,
                  bottom: AppSpacing.xl,
                  top: _numberClearance,
                  child: SingleChildScrollView(
                    reverse: true,
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SurpriseCardTags(
                          affinityPercent: suggestion.affinityPercent,
                          mediaType: item.type,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.display,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            if (meta != null)
                              Flexible(
                                child: Text(
                                  meta,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodySm.copyWith(
                                    color: AppColors.inkMuted,
                                  ),
                                ),
                              ),
                            if (rating != null) ...[
                              const SizedBox(width: AppSpacing.md),
                              const Icon(
                                AppIcons.starFill,
                                size: _starSize,
                                color: AppColors.accent,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(rating, style: AppTextStyles.bodySmStrong),
                            ],
                          ],
                        ),
                        if (tagline != null && tagline.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            '«$tagline»',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySm.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                        if (suggestion.platforms.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.md),
                          SurpriseCardPlatforms(
                            platforms: suggestion.platforms,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const double _starSize = 14;

  /// The text block never grows up into the card number's corner.
  static const double _numberClearance = 128;
}

class _Poster extends StatelessWidget {
  const _Poster({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final u = url;
    if (u == null || u.isEmpty) return const SizedBox.shrink();
    return Image.network(
      u,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
    );
  }
}
