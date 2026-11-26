import 'package:flutter/material.dart';

import '../../../core/domain/entities/genre.dart';
import '../../../core/domain/entities/release_status.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../l10n/release_status_localization.dart';
import '../poster_badge.dart';
import 'media_meta_line.dart';
import 'rating_ring.dart';
import '../app_network_image.dart';
import '../image_use.dart';

/// D1/D2's header — `docs/SCREENS.md` D1: a 420 px backdrop (TMDB's 16:9
/// backdrop, or the poster when there isn't one) that fades into the page,
/// the back button on top, and over the fade the left-aligned title with
/// the italic tagline under it, the [RatingRing] at the right of the title and
/// the meta line (year · country · genres · language) at the foot.
///
/// A title that isn't out yet, or is only in cinemas, carries a tag above its
/// title ([releaseStatus]).
///
/// The trailer button and the action toggles are the row below it
/// (`media_detail_action_row.dart`).
class MediaDetailHeader extends StatelessWidget {
  const MediaDetailHeader({
    super.key,
    required this.imageUrl,
    required this.title,
    this.tagline,
    this.releaseStatus,
    this.metaPrefix = '',
    this.genres = const [],
    this.language,
    this.voteAverage = 0,
    this.showRating = true,
  });

  /// Backdrop URL, or the poster's when TMDB has no backdrop; `null` shows
  /// a flat placeholder.
  final String? imageUrl;
  final String title;
  final String? tagline;

  /// "Coming Mar 14" / "In theaters", as a tag above the title; `null` for
  /// an ordinary released title.
  final ReleaseStatus? releaseStatus;

  /// The meta line: year(s) and country, then the genres, then the original
  /// language's name (plain text, no links).
  final String metaPrefix;
  final List<Genre> genres;
  final String? language;

  /// TMDB's vote average for the ring; [showRating] is `false` for a title
  /// that isn't out yet (TMDB reports 0.0), which has no ring.
  final double voteAverage;
  final bool showRating;

  /// Public: the assembled screens need the same value to know when the
  /// title has "scrolled past the top" and the compact bar should appear.
  static const double height = 420;

  static const double _topScrim = 0.35;

  @override
  Widget build(BuildContext context) {
    final tagline = this.tagline;
    final titleText = Text(
      title,
      style: AppTextStyles.displayTitle,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _Backdrop(imageUrl: imageUrl),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0, 0.3, 1],
                colors: [
                  AppColors.surface.withValues(alpha: _topScrim),
                  AppColors.surface.withValues(alpha: 0),
                  AppColors.surface,
                ],
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            bottom: AppSpacing.lg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (releaseStatus case final status?) ...[
                  // The same amber tag for "not out yet" and "in theaters".
                  PosterBadge(
                    label: status.headerLabel(context.l10n),
                    amber: true,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          titleText,
                          if (tagline != null && tagline.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              tagline,
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.inkMuted,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (showRating) ...[
                      const SizedBox(width: AppSpacing.lg),
                      RatingRing(rating: voteAverage),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                MediaMetaLine(
                  prefix: metaPrefix,
                  genres: genres,
                  language: language,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return AppNetworkImage(
      url: imageUrl,
      use: ImageUse.backdrop,
      alignment: Alignment.topCenter,
    );
  }
}
