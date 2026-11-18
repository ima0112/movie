import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../l10n/l10n_extension.dart';

/// How a thumbnail of the strip looks.
enum SurpriseThumbnailState {
  /// Just the poster with a fine border — a card that isn't on top.
  normal,

  /// An accent border and a soft glow — the card on top.
  current,

  /// The card is in Watch later: a bookmark badge, bottom-right.
  saved,

  /// The chosen card (the closing screen): a check in place of the bookmark.
  chosen,
}

/// The strip of small poster thumbnails (one per card, up to five) at the top
/// of Surprise me's deck: a direct way to a card and a record of what was
/// saved. Each thumbnail is drawn at 28×38 but its touch area is 48×48. With
/// [onTap] null the strip is visible but inactive (the closing screen).
///
/// There is no "passed" or "discarded" state: passing a card means nothing.
///
/// Pure presentation — everything comes in by parameter.
class SurpriseThumbnailStrip extends StatelessWidget {
  const SurpriseThumbnailStrip({
    super.key,
    required this.posterUrls,
    required this.currentIndex,
    required this.savedIndexes,
    this.chosenIndex,
    this.onTap,
  });

  /// One poster URL (or `null`) per card.
  final List<String?> posterUrls;
  final int currentIndex;
  final Set<int> savedIndexes;
  final int? chosenIndex;
  final ValueChanged<int>? onTap;

  static const double thumbWidth = 28;
  static const double thumbHeight = 38;

  /// The touch area: 48 tall, but only 34 wide — close enough that the strip
  /// reads as one group.
  static const double touchHeight = 48;
  static const double touchWidth = 34;

  SurpriseThumbnailState _stateOf(int i) {
    if (i == chosenIndex) return SurpriseThumbnailState.chosen;
    if (i == currentIndex && chosenIndex == null) {
      return SurpriseThumbnailState.current;
    }
    if (savedIndexes.contains(i)) return SurpriseThumbnailState.saved;
    return SurpriseThumbnailState.normal;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < posterUrls.length; i++)
          _Thumbnail(
            number: i + 1,
            posterUrl: posterUrls[i],
            state: _stateOf(i),
            saved: savedIndexes.contains(i),
            onTap: onTap == null ? null : () => onTap!(i),
          ),
      ],
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.number,
    required this.posterUrl,
    required this.state,
    required this.saved,
    required this.onTap,
  });

  final int number;
  final String? posterUrl;
  final SurpriseThumbnailState state;
  final bool saved;
  final VoidCallback? onTap;

  static const double _badge = 12;
  static const double _badgeIcon = 8;
  static const double _glow = 8;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isCurrent = state == SurpriseThumbnailState.current;
    final badge = switch (state) {
      SurpriseThumbnailState.chosen => AppIcons.check,
      _ when saved => AppIcons.watchLaterFill,
      _ => null,
    };
    final url = posterUrl;

    return Semantics(
      button: onTap != null,
      selected: isCurrent,
      label: saved
          ? l10n.surpriseThumbnailSaved(number)
          : l10n.surpriseThumbnailLabel(number),
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: SurpriseThumbnailStrip.touchWidth,
          height: SurpriseThumbnailStrip.touchHeight,
          child: Center(
            child: SizedBox(
              width: SurpriseThumbnailStrip.thumbWidth,
              height: SurpriseThumbnailStrip.thumbHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSpacing.xs),
                        border: Border.all(
                          color: isCurrent
                              ? AppColors.accent
                              : AppColors.lineStrong,
                          width: isCurrent ? 2 : 1,
                        ),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: AppColors.accent.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: _glow,
                                ),
                              ]
                            : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppSpacing.xs),
                        child: url == null || url.isEmpty
                            ? const ColoredBox(color: AppColors.surfaceRaised2)
                            : Image.network(
                                url,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const ColoredBox(
                                      color: AppColors.surfaceRaised2,
                                    ),
                              ),
                      ),
                    ),
                  ),
                  if (badge != null)
                    Positioned(
                      right: -AppSpacing.xs,
                      bottom: -AppSpacing.xs,
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                        child: SizedBox(
                          width: _badge,
                          height: _badge,
                          child: Icon(
                            badge,
                            size: _badgeIcon,
                            color: AppColors.onAccent,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
