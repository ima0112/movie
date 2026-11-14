import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/l10n_extension.dart';
import 'poster_badge.dart';

/// The poster card sizes used across PakoTV.
///
/// Source of truth: `docs/DESIGN_SYSTEM.md` section 5.1 and
/// `docs/SCREENS.md` B1 (Discover). The pixel dimensions are literal
/// values from those documents, not part of the generic `AppSpacing`
/// scale — they describe this one component, not a layout token.
enum MediaCardSize {
  /// 110×165. Carousel rows (3.2 cards visible).
  carousel(width: 110, height: 165, aspectRatio: null),

  /// 150×225. B2's "Top today" (the lead section).
  carouselLarge(width: 150, height: 225, aspectRatio: null),

  /// 130×195. B2's "New releases" and "Hidden gems".
  carouselMedium(width: 130, height: 195, aspectRatio: null),

  /// 90×135. B2's "Coming soon" (a compact strip).
  carouselSmall(width: 90, height: 135, aspectRatio: null),

  /// 330×380. The Discover hero.
  hero(width: 330, height: 380, aspectRatio: null),

  /// 2:3, fluid — C1's 3-column grid. Unlike [carousel]/[hero], this
  /// variant has no fixed pixel size of its own — [width]/[height] are
  /// unused (`0`) and the card instead sizes itself to whatever width
  /// its `GridView` cell gives it via [aspectRatio].
  grid(width: 0, height: 0, aspectRatio: 2 / 3);

  const MediaCardSize({
    required this.width,
    required this.height,
    required this.aspectRatio,
  });

  /// Unused (`0`) for [grid] — see [aspectRatio].
  final double width;
  final double height;

  /// Only set for [grid] — the other two variants size themselves from
  /// [width]/[height] directly.
  final double? aspectRatio;
}

/// Translucent black used to paint tags and buttons over a poster (reason
/// tag, "TV" tag, save button) — the "60% black background" called out
/// repeatedly in `docs/SCREENS.md`. Not a brand color, so it isn't part of
/// `AppColors`.
const Color _scrim = Color(0x99000000);

/// A poster card. Pure presentation: no feature or network dependency,
/// everything comes in by parameter. Pass `posterUrl: null` to render a
/// flat placeholder instead of an image (useful to preview without a
/// network fetch).
class MediaCard extends StatelessWidget {
  const MediaCard({
    super.key,
    required this.size,
    required this.title,
    this.posterUrl,
    this.showTypeTag = false,
    this.reasonTag,
    this.metadata,
    this.onSaveTap,
    this.isSaved = false,
    this.saveButton,
    this.onTap,
    this.onLongPress,
    this.width,
  });

  final MediaCardSize size;

  /// Overrides the fixed [MediaCardSize] width (the hero narrows on a small
  /// phone). Ignored by [MediaCardSize.grid].
  final double? width;

  /// Used as the card's accessibility label. Only rendered visually on
  /// [MediaCardSize.hero] — carousel cards show no title or year
  /// underneath the poster (see `docs/SCREENS.md` B1).
  final String title;

  final String? posterUrl;

  /// Small "TV" pill in the corner — TV shows only.
  final bool showTypeTag;

  /// Hero only. E.g. "For you" (rendered on an amber pill; any other text
  /// gets the neutral scrim pill).
  final String? reasonTag;

  /// Hero only. Gray line under the title, e.g. "2019 · Mystery, Comedy ·
  /// Movie" — see `docs/SCREENS.md` B1.
  final String? metadata;

  /// Hero only. Circular save (Watch later) button, top right. Ignored
  /// when [saveButton] is provided.
  final VoidCallback? onSaveTap;

  /// Whether the built-in save button renders its "already saved" look
  /// (filled, amber) — see `docs/SCREENS.md` B1 ("amber if already in
  /// Watch later"). Only affects the button built from [onSaveTap]; has
  /// no effect when [saveButton] is provided.
  final bool isSaved;

  /// Hero only. A custom widget for the save-button slot (top right),
  /// used instead of the built-in one. For when the button's look needs
  /// to react to something this card doesn't know about — e.g. a
  /// `BlocSelector` watching whether this item is saved — without making
  /// this whole card (or its carousel) rebuild for that. Takes priority
  /// over [onSaveTap]/[isSaved] when provided.
  final Widget? saveButton;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  bool get _isHero => size == MediaCardSize.hero;

  @override
  Widget build(BuildContext context) {
    final poster = ClipRRect(
      borderRadius: BorderRadius.circular(
        _isHero ? AppSpacing.radiusXl : AppSpacing.radiusMd,
      ),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _Poster(posterUrl: posterUrl),
            if (_isHero) const _HeroFade(),
            if (_isHero)
              Positioned(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                bottom: AppSpacing.xl,
                child: _HeroCaption(
                  title: title,
                  reasonTag: reasonTag,
                  metadata: metadata,
                ),
              ),
            if (showTypeTag)
              const Positioned(
                left: AppSpacing.xs,
                top: AppSpacing.xs,
                child: _TvTag(),
              ),
            if (_isHero && (saveButton != null || onSaveTap != null))
              Positioned(
                right: AppSpacing.xs,
                top: AppSpacing.xs,
                child:
                    saveButton ??
                    MediaCardSaveButton(onTap: onSaveTap!, isSaved: isSaved),
              ),
          ],
        ),
      ),
    );

    return Semantics(
      label: title,
      image: true,
      child: size.aspectRatio != null
          ? AspectRatio(aspectRatio: size.aspectRatio!, child: poster)
          : SizedBox(
              width: width ?? size.width,
              height: size.height,
              child: poster,
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
    if (url == null) {
      return const ColoredBox(color: AppColors.surfaceRaised2);
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const ColoredBox(color: AppColors.surfaceRaised2);
      },
    );
  }
}

/// The hero poster's bottom melts into the page, as the detail header's does:
/// a long, eased ramp from transparent (30% down the card) through most of
/// the way dark by 75%, to **practically opaque by 90%** and fully the page's
/// black at the foot — so the poster's art is gone before the caption's last
/// line, the card has no visible bottom edge, and the caption sits on a dark,
/// legible fade.
class _HeroFade extends StatelessWidget {
  const _HeroFade();

  /// `(stop, opacity of the page color)` — see [heroFadeStops].
  static const List<(double, double)> _ramp = heroFadeStops;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [for (final (stop, _) in _ramp) stop],
          colors: [
            for (final (_, opacity) in _ramp)
              AppColors.surface.withValues(alpha: opacity),
          ],
        ),
      ),
    );
  }
}

/// The hero fade's ramp: `(stop, opacity)` pairs, top to bottom.
@visibleForTesting
const List<(double, double)> heroFadeStops = [
  (0.30, 0),
  (0.55, 0.4),
  (0.75, 0.82),
  (0.90, 0.98),
  (1, 1),
];

class _HeroCaption extends StatelessWidget {
  const _HeroCaption({
    required this.title,
    required this.reasonTag,
    required this.metadata,
  });

  final String title;
  final String? reasonTag;
  final String? metadata;

  @override
  Widget build(BuildContext context) {
    final tag = reasonTag;
    final meta = metadata;
    // Centered at the bottom of the card.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (tag != null) ...[
          PosterBadge(label: tag, amber: tag == 'For you'),
          const SizedBox(height: AppSpacing.sm),
        ],
        Text(
          title,
          style: AppTextStyles.h1,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (meta != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            meta,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

class _TvTag extends StatelessWidget {
  const _TvTag();

  @override
  Widget build(BuildContext context) {
    return PosterBadge(label: context.l10n.mediaTypeTvTag);
  }
}

/// The hero's circular save (Watch later) button. Public because a screen
/// wiring this up to a Cubit needs to drop its own — e.g. `BlocSelector`
/// wrapped — instance into [MediaCard.saveButton] with the same look.
class MediaCardSaveButton extends StatelessWidget {
  const MediaCardSaveButton({
    super.key,
    required this.onTap,
    this.isSaved = false,
  });

  final VoidCallback onTap;

  /// Amber + filled icon when already saved — see `docs/SCREENS.md` B1
  /// ("amber if already in Watch later").
  final bool isSaved;

  // Literal from docs/SCREENS.md ("Circular save button (36 px)"), not an
  // AppSpacing token — a fixed size of this one component, not a layout
  // value.
  static const double _diameter = 36;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _diameter,
        height: _diameter,
        decoration: BoxDecoration(
          color: isSaved ? AppColors.accent : _scrim,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isSaved ? AppIcons.watchLaterFill : AppIcons.watchLater,
          size: 20,
          color: isSaved ? AppColors.onAccent : AppColors.ink,
        ),
      ),
    );
  }
}
