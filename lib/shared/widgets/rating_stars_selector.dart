import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';

/// H2's "5-star selector (optional)" (`docs/SCREENS.md` H2) — tapping the
/// already-selected star clears it back to `null` ("optional" meaning a
/// rating can genuinely be left unset, not just default to 1).
///
/// Split out of `mark_as_watched_sheet.dart` per CLAUDE.md rule 11. Pure
/// presentation — no feature dependency, everything comes in by
/// parameter.
class RatingStarsSelector extends StatelessWidget {
  const RatingStarsSelector({
    super.key,
    required this.rating,
    required this.onChanged,
  });

  final int? rating;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var star = 1; star <= 5; star++)
          GestureDetector(
            onTap: () => onChanged(star == rating ? null : star),
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: Icon(
                AppIcons.starFill,
                size: 32,
                color: rating != null && star <= rating!
                    ? AppColors.accent
                    : AppColors.lineStrong,
              ),
            ),
          ),
      ],
    );
  }
}
