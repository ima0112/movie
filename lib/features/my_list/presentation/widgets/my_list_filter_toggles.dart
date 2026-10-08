import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';

/// H9's minimum-rating and hide-watched rows, split out of
/// `my_list_filter_sheet.dart` per CLAUDE.md rule 11. Pure presentation —
/// the sheet owns the draft `TabFilter` and passes each row its value.

/// H9: "in Watched, minimum rating (★1–5)". Tapping the already-selected
/// star clears the minimum, matching a filter's usual "toggle off" feel.
class MinStarsFilterRow extends StatelessWidget {
  const MinStarsFilterRow({
    super.key,
    required this.minStars,
    required this.onChanged,
  });

  final int? minStars;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var star = 1; star <= 5; star++)
          GestureDetector(
            onTap: () => onChanged(star == minStars ? null : star),
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: Icon(
                AppIcons.starFill,
                size: 28,
                color: minStars != null && star <= minStars!
                    ? AppColors.accent
                    : AppColors.inkDim,
              ),
            ),
          ),
      ],
    );
  }
}

/// H9: "in Favorites and Watch later, 'Hide what I've watched'".
class HideWatchedFilterRow extends StatelessWidget {
  const HideWatchedFilterRow({
    super.key,
    required this.hideWatched,
    required this.onChanged,
  });

  final bool hideWatched;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(context.l10n.myListHideWatchedToggle, style: AppTextStyles.body),
        Switch(
          value: hideWatched,
          onChanged: onChanged,
          activeThumbColor: AppColors.accent,
        ),
      ],
    );
  }
}
