import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../../../shared/widgets/image_use.dart';

/// `PosterWallColumn`'s own rendered content: [copies] consecutive
/// repetitions of [slots], stacked top to bottom — split out so that
/// file stays under rule 11's 150-line limit.
///
/// `crossAxisAlignment: stretch` below isn't decorative: a `Column`'s
/// default (`center`) only gives children a *loose* width constraint,
/// and `Image.network` with no explicit width sizes itself to its own
/// natural aspect ratio within that — which happens to come out full
/// width here only because TMDB posters are themselves ~2:3, the same
/// ratio `cardHeight`/column width already uses. `stretch` makes every
/// tile's width exactly the column's own, by construction, not by that
/// coincidence — and makes a placeholder `ColoredBox` (which has no
/// aspect ratio of its own to fall back on) fill correctly too.
class PosterWallTiles extends StatelessWidget {
  const PosterWallTiles({
    super.key,
    required this.slots,
    required this.copies,
    required this.cardHeight,
  });

  final List<String?> slots;
  final int copies;
  final double cardHeight;

  /// The wall loads a dozen posters at once, so each fades in faster than the
  /// app's usual 150 ms: whatever the splash couldn't warm still doesn't read
  /// as a second splash.
  static const Duration fade = Duration(milliseconds: 80);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var copy = 0; copy < copies; copy++)
          for (final url in slots)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: SizedBox(
                height: cardHeight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: AppNetworkImage(
                    url: url,
                    use: ImageUse.poster,
                    fade: fade,
                  ),
                ),
              ),
            ),
      ],
    );
  }
}
