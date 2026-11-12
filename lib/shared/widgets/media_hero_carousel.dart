import 'package:flutter/material.dart';

import '../../core/domain/entities/media_item.dart';
import '../../core/theme/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/genre_localization.dart';
import '../../l10n/l10n_extension.dart';
import '../../l10n/media_type_localization.dart';
import 'media_card.dart';

/// "2019 · Mystery, Comedy · Movie" — the hero's metadata line, per
/// `docs/SCREENS.md` B1.
String _heroMetadata(MediaItem item, AppLocalizations l10n) {
  final parts = <String>[
    if (item.releaseDate != null) '${item.releaseDate!.year}',
    if (item.genres.isNotEmpty)
      item.genres.map((genre) => genre.localizedName(l10n)).join(', '),
    item.type.localizedSingular(l10n),
  ];
  return parts.join(' · ');
}

/// The Discover hero (`docs/SCREENS.md` B1): big snapping cards in a row that
/// **loops** — after the last banner the first comes back.
///
/// Layout: the first card starts on the page's [AppSpacing.screenMargin]
/// like everything else on the screen, cards are [AppSpacing.md] apart, and
/// the next card peeks in by [_peek] on the right. The card is
/// [MediaCardSize.hero]'s 330 px wide, narrowed on small phones so the
/// peek never disappears.
///
/// Pure presentation, no Bloc: [saveButtonBuilder] lets the caller put a
/// button (with its own narrow subscription) on each card without this
/// carousel, or any other card, rebuilding for it (CLAUDE.md rule 9).
/// Give it a `ValueKey` that changes with the content (the segment) so a
/// new list starts again at its first banner.
class MediaHeroCarousel extends StatefulWidget {
  const MediaHeroCarousel({
    super.key,
    required this.items,
    this.saveButtonBuilder,
    this.onSaveTap,
    this.onItemTap,
  });

  final List<MediaItem> items;

  /// Replaces the built-in save button on the card for that item.
  final Widget Function(MediaItem item)? saveButtonBuilder;

  /// Used for the built-in save button when [saveButtonBuilder] is `null`.
  final void Function(MediaItem item)? onSaveTap;
  final void Function(MediaItem item)? onItemTap;

  static const double _peek = 24;

  /// How many laps' worth of pages there are before and after the start, so
  /// the carousel can be swiped far in either direction.
  static const int _laps = 1000;

  @override
  State<MediaHeroCarousel> createState() => _MediaHeroCarouselState();
}

class _MediaHeroCarouselState extends State<MediaHeroCarousel> {
  PageController? _controller;
  double? _fraction;

  bool get _loops => widget.items.length > 1;

  /// A controller for [fraction] (the page width over the viewport's),
  /// replaced only when the screen width changes.
  PageController _controllerFor(double fraction) {
    if (_controller == null || _fraction != fraction) {
      _controller?.dispose();
      _fraction = fraction;
      _controller = PageController(
        viewportFraction: fraction,
        initialPage: _loops ? widget.items.length * MediaHeroCarousel._laps : 0,
      );
    }
    return _controller!;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    // Card + the gap to the next one, over the viewport (the page minus the
    // left margin the first card sits on).
    final cardWidth =
        (width -
                AppSpacing.screenMargin -
                AppSpacing.md -
                MediaHeroCarousel._peek)
            .clamp(0.0, MediaCardSize.hero.width);
    final viewport = width - AppSpacing.screenMargin;
    final controller = _controllerFor((cardWidth + AppSpacing.md) / viewport);

    final items = widget.items;
    final onSave = widget.onSaveTap;
    final buildSaveButton = widget.saveButtonBuilder;
    final onTap = widget.onItemTap;

    return SizedBox(
      height: MediaCardSize.hero.height,
      child: Padding(
        padding: const EdgeInsets.only(left: AppSpacing.screenMargin),
        child: PageView.builder(
          controller: controller,
          // The previous card slides off the screen's edge, not the margin.
          clipBehavior: Clip.none,
          // Without this the first card would be centered.
          padEnds: false,
          itemCount: _loops ? null : items.length,
          itemBuilder: (context, index) {
            final item = items[index % items.length];
            return Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: MediaCard(
                  size: MediaCardSize.hero,
                  width: cardWidth,
                  title: item.title,
                  posterUrl: item.posterUrl,
                  metadata: _heroMetadata(item, context.l10n),
                  saveButton: buildSaveButton?.call(item),
                  onSaveTap: buildSaveButton == null && onSave != null
                      ? () => onSave(item)
                      : null,
                  onTap: onTap == null ? null : () => onTap(item),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
