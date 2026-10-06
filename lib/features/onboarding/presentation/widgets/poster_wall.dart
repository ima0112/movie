import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import 'poster_wall_column.dart';
import 'poster_wall_geometry.dart';

/// Step 0's background — `docs/SCREENS.md` A2: "poster wall (4 staggered
/// columns, 55% opacity, slow vertical drift; static with 'reduce
/// motion')... Offline: same wall with placeholders."
///
/// Pure presentation (CLAUDE.md rule 9): takes already-resolved poster
/// URLs — fetching a varied pool is the eventual screen's job
/// (`MediaRepository.getPosterWallItems`, deliberately not the smaller,
/// shared `getCarouselSection(popularThisWeek)` — see that method's own
/// doc comment). Empty [posterUrls] renders every tile as a placeholder
/// block.
///
/// Stateless itself — each [PosterWallColumn] owns its own
/// `AnimationController` (see that file's own doc comment for why).
/// This widget splits [posterUrls] into 4 *disjoint* lists (so the same
/// poster never appears in two columns on screen at once), gives each
/// column a distinct start phase, drift direction, and speed (the only
/// way the 4 columns differ from one another), and lays them out with
/// `AppSpacing.sm` between columns — the *only* spacing in this wall;
/// there's still no top/bottom offset anywhere (that was the earlier,
/// broken design). No outer margin either: columns 1 and 4 touch the
/// screen edges, matching "full bleed."
class PosterWall extends StatelessWidget {
  const PosterWall({super.key, this.posterUrls = const []});

  final List<String?> posterUrls;

  static const double _opacity = 0.55;
  static const int _columnCount = 4;

  // The only stagger mechanism. Odd columns (index 0, 2) drift up; even
  // columns (index 1, 3) drift down — docs/SCREENS.md A2 just says
  // "staggered", these specific values/directions are this task's own.
  static const List<double> _startPhases = [0, 0.35, 0.15, 0.6];
  static const List<bool> _goesUp = [true, false, true, false];

  @override
  Widget build(BuildContext context) {
    final columns = _distribute(posterUrls, _columnCount);

    return Opacity(
      opacity: _opacity,
      child: Row(
        children: [
          for (var i = 0; i < columns.length; i++) ...[
            // The same AppSpacing.sm as the vertical gap between cards
            // within a column (poster_wall_tiles.dart) — one constant,
            // both directions, so the spacing reads as uniform
            // (CLAUDE.md rule 4: never a bare literal here either).
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: PosterWallColumn(
                urls: columns[i],
                startPhase: _startPhases[i],
                goesUp: _goesUp[i],
                speed: PosterWallConfig.columnSpeeds[i],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Round-robins posters into [columnCount] *disjoint* lists — every
  // url appears in exactly one column, so the same poster never shows
  // in two columns at once. An empty/short list of real posters is
  // padded with `null`s (placeholder tiles); `PosterWallColumn` itself
  // pads further if a column's own share is still too small to satisfy
  // its own "loop height >= screen height" guarantee.
  static List<List<String?>> _distribute(List<String?> urls, int columnCount) {
    final source = urls.isEmpty
        ? List<String?>.filled(columnCount * 3, null)
        : urls;
    final columns = List.generate(columnCount, (_) => <String?>[]);
    for (var i = 0; i < source.length; i++) {
      columns[i % columnCount].add(source[i]);
    }
    return columns;
  }
}
