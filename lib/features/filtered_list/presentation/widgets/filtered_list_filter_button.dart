import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../cubit/filtered_list_cubit.dart';
import '../cubit/filtered_list_state.dart';

/// The app bar's filter icon (opens H8) with a small amber badge counting the
/// filters that are set, none when there are none. Watches only that count
/// (CLAUDE.md rule 9).
class FilteredListFilterButton extends StatelessWidget {
  const FilteredListFilterButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  static const double _badgeSize = 18;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<FilteredListCubit, FilteredListState, int>(
      selector: (state) => state.filter.activeFilterCount,
      builder: (context, count) {
        return IconButton(
          tooltip: context.l10n.exploreFilterTooltip,
          onPressed: onPressed,
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(AppIcons.filter, color: AppColors.ink),
              if (count > 0)
                Positioned(
                  top: -AppSpacing.sm,
                  right: -AppSpacing.sm,
                  child: Container(
                    width: _badgeSize,
                    height: _badgeSize,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$count',
                      style: AppTextStyles.captionStrong.copyWith(
                        color: AppColors.onAccent,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
