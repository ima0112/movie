import 'package:flutter/widgets.dart';

import '../../app/di.dart';
import '../../core/data/tmdb/tmdb_configuration_service.dart';
import '../../core/data/tmdb/tmdb_image_resizer.dart';
import '../../core/data/tmdb/tmdb_image_urls.dart';
import '../../core/network/image_cache/app_image_cache.dart';
import '../../core/theme/app_colors.dart';
import 'image_use.dart';

/// **The** way the app shows a network image — a TMDB poster, a backdrop, a
/// cast photo, a logo. No other widget builds an `Image.network` (a guard test
/// checks): they all get, from here, the same disk cache (`AppImageCache`), the
/// same decode-at-the-size-it's-drawn policy and the same look while loading or
/// failing (`docs/DECISIONS.md`, "Caching").
///
/// - **Size.** The image is drawn [width] wide (or as wide as its parent allows)
///   at the screen's pixel ratio; that many pixels is what it asks TMDB for —
///   `TmdbImageResizer` rewrites the URL to the smallest size that covers it,
///   capped by [use] — and what it is decoded at (`cacheWidth`), so a long
///   scroll of posters doesn't keep full-size bitmaps in memory.
/// - **Loading and failure.** A flat `AppColors.imagePlaceholder` tile: no
///   spinner. A loaded image fades in over it (briefly; not at all with "reduce
///   motion", nor when it was already in memory).
/// - **No URL.** The same tile (or [fallback], when given, here and on failure).
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    required this.use,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.fallback,
    this.fade,
  });

  /// The image's address, or `null` for none.
  final String? url;
  final ImageUse use;

  /// The size it is drawn at, when its parent doesn't fix it already.
  final double? width;
  final double? height;
  final BoxFit fit;
  final AlignmentGeometry alignment;

  /// What to show when there is no URL or the image can't be loaded, instead of
  /// the flat tile (a cast photo's monogram, the next thumbnail to try).
  final WidgetBuilder? fallback;

  /// How long a loaded image takes to fade in over the placeholder, when the
  /// image doesn't say otherwise ([fade]).
  static const Duration fadeDuration = Duration(milliseconds: 150);

  /// This image's own fade-in, instead of [fadeDuration] (the onboarding's
  /// poster wall, which loads a dozen at once, uses a shorter one).
  final Duration? fade;

  /// Loads [url] into the cache now — what is about to be shown (the next
  /// posters of a carousel, the title about to be opened) — with the same size
  /// and keys the widget will use. [logicalWidth] is the width it will be drawn
  /// at.
  static Future<void> precache(
    BuildContext context,
    String? url, {
    required ImageUse use,
    double? logicalWidth,
  }) {
    if (url == null) return Future.value();
    final source = _source(context, url, use, logicalWidth);
    return _cache().precache(
      context,
      source.url,
      cacheWidth: source.cacheWidth,
    );
  }

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    if (url == null) return _fallback(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final drawnWidth =
            width ??
            (constraints.hasBoundedWidth ? constraints.maxWidth : null);
        final source = _source(context, url, use, drawnWidth);
        final fadeFor = MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : fade ?? fadeDuration;
        return ColoredBox(
          color: AppColors.imagePlaceholder,
          child: Image(
            image: _cache().provider(source.url, cacheWidth: source.cacheWidth),
            width: width,
            height: height,
            fit: fit,
            alignment: alignment,
            frameBuilder: (context, child, frame, loadedSynchronously) {
              if (loadedSynchronously || fadeFor == Duration.zero) return child;
              return AnimatedOpacity(
                opacity: frame == null ? 0 : 1,
                duration: fadeFor,
                child: child,
              );
            },
            errorBuilder: (context, error, stackTrace) => _fallback(context),
          ),
        );
      },
    );
  }

  Widget _fallback(BuildContext context) =>
      fallback?.call(context) ??
      const ColoredBox(color: AppColors.imagePlaceholder);

  static ({String url, int? cacheWidth}) _source(
    BuildContext context,
    String url,
    ImageUse use,
    double? logicalWidth,
  ) {
    if (logicalWidth == null || !logicalWidth.isFinite || logicalWidth <= 0) {
      return (url: url, cacheWidth: null);
    }
    final pixels = logicalWidth * MediaQuery.devicePixelRatioOf(context);
    final kind = use.kind;
    final maxSize = use.maxSize;
    return (
      url: kind == null || maxSize == null
          ? url
          : TmdbImageResizer.resize(
              url: url,
              kind: kind,
              neededPixels: pixels,
              maxSize: maxSize,
              config: _config(),
            ),
      cacheWidth: pixels.ceil(),
    );
  }

  /// The configuration TMDB reports (or the well-known fallback until it
  /// arrives, and in environments that have no service): synchronous either way.
  static TmdbImagesConfig _config() {
    if (!getIt.isRegistered<TmdbConfigurationService>()) {
      return const TmdbImagesConfig.fallback();
    }
    final service = getIt<TmdbConfigurationService>();
    service.load();
    return service.current;
  }

  static AppImageCache _cache() => getIt.isRegistered<AppImageCache>()
      ? getIt<AppImageCache>()
      : const NetworkImageCache();
}
