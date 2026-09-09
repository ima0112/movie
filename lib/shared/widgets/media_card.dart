import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// The poster card sizes used across PakoTV.
///
/// Source of truth: `docs/DESIGN_SYSTEM.md` section 5.1 and
/// `docs/SCREENS.md` B1 (Discover). The pixel dimensions are literal
/// values from those documents, not part of the generic `AppSpacing`
/// scale — they describe this one component, not a layout token.
enum MediaCardSize {
  /// 110×165. Carousel rows (3.2 cards visible).
  carousel(width: 110, height: 165),

  /// 330×440 (3:4). The Discover hero.
  hero(width: 330, height: 440);

  const MediaCardSize({required this.width, required this.height});

  final double width;
  final double height;
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
    this.onSaveTap,
    this.onTap,
    this.onLongPress,
  });

  final MediaCardSize size;

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

  /// Hero only. Circular save (Watch later) button, top right.
  final VoidCallback? onSaveTap;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  bool get _isHero => size == MediaCardSize.hero;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: title,
      image: true,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
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
                    left: AppSpacing.md,
                    right: AppSpacing.md,
                    bottom: AppSpacing.md,
                    child: _HeroCaption(title: title, reasonTag: reasonTag),
                  ),
                if (showTypeTag)
                  const Positioned(
                    left: AppSpacing.xs,
                    top: AppSpacing.xs,
                    child: _TvTag(),
                  ),
                if (_isHero && onSaveTap != null)
                  Positioned(
                    right: AppSpacing.xs,
                    top: AppSpacing.xs,
                    child: _SaveButton(onTap: onSaveTap!),
                  ),
              ],
            ),
          ),
        ),
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

/// Fade to black over the bottom 40% of the hero poster, so the caption
/// stays legible.
class _HeroFade extends StatelessWidget {
  const _HeroFade();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.6, 1],
          colors: [Colors.transparent, Color(0xFF000000)],
        ),
      ),
    );
  }
}

class _HeroCaption extends StatelessWidget {
  const _HeroCaption({required this.title, required this.reasonTag});

  final String title;
  final String? reasonTag;

  @override
  Widget build(BuildContext context) {
    final tag = reasonTag;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (tag != null) ...[
          _Pill(
            label: tag,
            amber: tag == 'For you',
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Text(
          title,
          style: AppTextStyles.h1,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _TvTag extends StatelessWidget {
  const _TvTag();

  @override
  Widget build(BuildContext context) {
    return const _Pill(label: 'TV', amber: false);
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.amber});

  final String label;
  final bool amber;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: amber ? AppColors.accent : _scrim,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: amber ? AppColors.onAccent : AppColors.ink,
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.onTap});

  final VoidCallback onTap;

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
        decoration: const BoxDecoration(color: _scrim, shape: BoxShape.circle),
        child: Icon(AppIcons.watchLater, size: 20, color: AppColors.ink),
      ),
    );
  }
}
