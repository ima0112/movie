import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../l10n/l10n_extension.dart';

/// H2's five stars: amber and filled up to the rating, an outline in muted
/// gray after it. Tapping the current rating again clears it (`null`).
/// Each star is a 48 px touch target with its own "N of 5" accessibility
/// label.
class RatingStarsSelector extends StatelessWidget {
  const RatingStarsSelector({
    super.key,
    required this.rating,
    required this.onChanged,
  });

  final int? rating;
  final ValueChanged<int?> onChanged;

  static const double _touchSize = 48;
  static const double _iconSize = 38;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var star = 1; star <= 5; star++)
          Semantics(
            button: true,
            selected: rating != null && star <= rating!,
            label: context.l10n.mediaDetailRatingStarLabel(star),
            excludeSemantics: true,
            child: GestureDetector(
              onTap: () => onChanged(star == rating ? null : star),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: _touchSize,
                height: _touchSize,
                child: Icon(
                  rating != null && star <= rating!
                      ? AppIcons.starFill
                      : AppIcons.star,
                  size: _iconSize,
                  color: rating != null && star <= rating!
                      ? AppColors.accent
                      : AppColors.inkMuted,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
