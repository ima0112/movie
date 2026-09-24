import 'package:flutter/material.dart';

import '../../../../core/domain/entities/genre.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// B2's "Genres" grid — "2-column tiles (96 px tall, backdrop of the
/// genre's most popular title dimmed to 40% with a fade to black, 16/500
/// name... offline → tile in `surfaceRaised` with just the name)"
/// (`docs/SCREENS.md` B2).
///
/// // TODO(tmdb): backdrop real del género — needs a "most popular
/// title per genre" query this app has no data source for yet (the same
/// shape gap `ExploreState`'s own doc comment already flagged). Every
/// tile uses the doc's own already-specified *offline* look
/// (`surfaceRaised`, name only) as its placeholder in the meantime,
/// rather than inventing a new color treatment rule 4 doesn't already
/// cover — once a real backdrop image exists, only this file's `_GenreTile`
/// needs to change, not its callers.
class GenreTileGrid extends StatelessWidget {
  const GenreTileGrid({super.key, required this.genres, required this.onTap});

  final List<Genre> genres;
  final ValueChanged<Genre> onTap;

  static const int _crossAxisCount = 2;
  static const double _tileHeight = 96;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _crossAxisCount,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisExtent: _tileHeight,
      ),
      itemCount: genres.length,
      itemBuilder: (context, index) {
        final genre = genres[index];
        return _GenreTile(genre: genre, onTap: () => onTap(genre));
      },
    );
  }
}

class _GenreTile extends StatelessWidget {
  const _GenreTile({required this.genre, required this.onTap});

  final Genre genre;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          // Placeholder — see this file's own top-of-file TODO(tmdb).
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            // SCREENS.md's "16/500" doesn't match an AppTextStyles token
            // exactly (h3 is the nearest: 15/600) — same "closest token,
            // not a one-off literal" call this codebase already makes
            // elsewhere (rule 4).
            child: Text(genre.name, style: AppTextStyles.h3),
          ),
        ),
      ),
    );
  }
}
