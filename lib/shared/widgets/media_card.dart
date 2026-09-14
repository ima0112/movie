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
    this.metadata,
    this.onSaveTap,
    this.isSaved = false,
    this.saveButton,
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
                        MediaCardSaveButton(
                          onTap: onSaveTap!,
                          isSaved: isSaved,
                        ),
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
        if (meta != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            meta,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
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
