import 'package:flutter/widgets.dart';

import '../../../app/di.dart';
import '../../../core/domain/entities/media_item.dart';
import '../../../core/domain/entities/result.dart';
import '../../../core/domain/repositories/media_repository.dart';
import '../../../core/domain/repositories/onboarding_repository.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_network_image.dart';
import '../../../shared/widgets/image_use.dart';
import 'widgets/poster_wall.dart';
import 'widgets/poster_wall_geometry.dart';

/// Warms the onboarding's poster wall **while the splash is still on screen**,
/// so the wall appears already painted instead of as a grid of placeholders
/// that fill in one by one (`docs/DECISIONS.md` "Caching").
///
/// A cold start has an empty in-memory image cache: even a poster saved on disk
/// has to be read and decoded before it can be drawn, which shows as a
/// placeholder and a fade. Done here, behind the splash, `Image` finds the
/// decoded poster already in memory and draws it in its first frame.
///
/// Only while the onboarding is still to be done: afterwards it does nothing.
/// The splash caps the wait (`SplashScreen.maxDuration`), so a slow first
/// install never holds it longer than before — the wall then loads on its own,
/// as it always did.
abstract final class PosterWallWarmup {
  static Future<Result<List<MediaItem>>>? _posters;

  /// The wall's posters, if the warm-up already asked for them — handed over
  /// once to the onboarding so the list isn't requested twice; `null` if it
  /// didn't run (the flow then asks for itself).
  static Future<Result<List<MediaItem>>>? takePosters() {
    final posters = _posters;
    _posters = null;
    return posters;
  }

  /// At most this many distinct posters are warmed (a tall screen shows about
  /// 6–7 per column on a phone).
  static const int maxPosters = 32;

  /// The splash's step: fetch the wall's list and decode what shows first.
  static Future<void> run(BuildContext context) async {
    if (getIt<OnboardingRepository>().isCompleted) return;
    final posters = _posters = getIt<MediaRepository>().getPosterWallItems();
    final result = await posters;
    if (result is! Success<List<MediaItem>> || !context.mounted) return;

    final size = MediaQuery.sizeOf(context);
    final columnWidth = tileWidth(size.width);
    final urls = visiblePosterUrls([
      for (final item in result.value) item.posterUrl,
    ], size);
    await Future.wait([
      for (final url in urls)
        AppNetworkImage.precache(
          context,
          url,
          use: ImageUse.poster,
          logicalWidth: columnWidth,
        ),
    ]);
  }

  /// A wall tile's width on a screen [screenWidth] wide: four columns with
  /// `AppSpacing.sm` between them, edge to edge — the same arithmetic as
  /// `PosterWall`, so the warmed poster is the one the tile asks for.
  static double tileWidth(double screenWidth) =>
      (screenWidth - AppSpacing.sm * (PosterWall.columnCount - 1)) /
      PosterWall.columnCount;

  /// The posters the wall shows in its first frame on a [screen]-sized
  /// viewport: for each column, the slots its start phase puts on screen
  /// (`driftOffset` at `t = 0` and `visibleTileRange`, the wall's own maths),
  /// without repeats, at most [maxPosters].
  @visibleForTesting
  static List<String> visiblePosterUrls(List<String?> posterUrls, Size screen) {
    final columns = PosterWall.distribute(posterUrls, PosterWall.columnCount);
    final cardHeight = tileWidth(screen.width) * 1.5;
    final tileHeight = cardHeight + AppSpacing.sm;
    final minSlots = ((screen.height + cardHeight) / tileHeight).ceil();

    final seen = <String>{};
    for (var i = 0; i < columns.length; i++) {
      final slots = columns[i].length >= minSlots
          ? columns[i]
          : [
              ...columns[i],
              ...List<String?>.filled(minSlots - columns[i].length, null),
            ];
      final loopHeight = slots.length * tileHeight;
      final range = visibleTileRange(
        offset: driftOffset(
          startPhase: PosterWall.startPhases[i],
          t: 0,
          goesUp: PosterWall.columnGoesUp[i],
          loopHeight: loopHeight,
        ),
        loopHeight: loopHeight,
        viewportHeight: screen.height,
        tileHeight: tileHeight,
      );
      for (var slot = range.firstIndex; slot <= range.lastIndex; slot++) {
        final url = slots[slot % slots.length];
        if (url != null) seen.add(url);
      }
    }
    return seen.take(maxPosters).toList();
  }

  @visibleForTesting
  static void reset() => _posters = null;
}
