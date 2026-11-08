import 'package:flutter/material.dart';

import '../../../core/domain/entities/genre.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../scrim_back_button.dart';
import 'media_detail_title_block.dart';

/// D1/D2's header: full-bleed poster, fade to black, back button, and the
/// centered title/metadata/rating/genres block ([MediaDetailTitleBlock]).
///
/// Source of truth: `docs/SCREENS.md` D1 ("Header (55% of the height):
/// full-bleed poster... fade to black starting at 60%...") and D2 (same
/// shell, plus a status pill next to the title). Pure presentation —
/// [metadataLine] arrives pre-formatted (each screen's own per-field
/// logic differs — D1's "year · runtime · certification" vs. D2's
/// "years · seasons · episodes · rating") and [statusPill] is an opaque
/// slot the caller fills only for D2. No Bloc subscription of its own —
/// the assembling screen already knows it's loaded by the time this is
/// built (CLAUDE.md rule 9) and passes plain values down.
class MediaDetailHeader extends StatelessWidget {
  const MediaDetailHeader({
    super.key,
    required this.posterUrl,
    required this.title,
    required this.metadataLine,
    required this.voteAverage,
    required this.genres,
    this.onGenreTap,
    this.statusPill,
  });

  final String? posterUrl;
  final String title;
  final String metadataLine;
  final double voteAverage;
  final List<Genre> genres;

  /// Tapping a genre → C1 with that genre (and the screen's own media
  /// type). `null` until the assembled screen wires real navigation.
  final void Function(Genre genre)? onGenreTap;

  /// D2's "Airing"/"Ended" pill next to the title (`docs/SCREENS.md`
  /// D2). `null` renders nothing extra — D1's own shape.
  final Widget? statusPill;

  // docs/SCREENS.md D1: "Header (55% of the height)". Public: the
  // assembled screen needs the same value to know when the title has
  // "scrolled past the top" and the compact bar should appear.
  static const double heightFraction = 0.55;
  static const List<double> _fadeStops = [0.6, 1];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * heightFraction,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _Poster(posterUrl: posterUrl),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: _fadeStops,
                colors: [Colors.transparent, Color(0xFF000000)],
              ),
            ),
          ),
          const ScrimBackButton(),
          Positioned(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            bottom: AppSpacing.xl,
            child: MediaDetailTitleBlock(
              title: title,
              metadataLine: metadataLine,
              voteAverage: voteAverage,
              genres: genres,
              onGenreTap: onGenreTap,
              statusPill: statusPill,
            ),
          ),
        ],
      ),
    );
  }
}

class _Poster extends StatelessWidget {
  const _Poster({required this.posterUrl});

  final String? posterUrl;

  @override
  Widget build(BuildContext context) {
    final url = posterUrl;
    if (url == null) return const ColoredBox(color: AppColors.surfaceRaised2);
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const ColoredBox(color: AppColors.surfaceRaised2),
    );
  }
}
