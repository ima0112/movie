import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../cubit/my_list_cubit.dart';
import 'my_list_filter_sheet.dart';

/// B4's top bar: "'My List' title and a single icon on the right,
/// filters (→ H9; amber if filters are active)" (`docs/SCREENS.md` B4).
///
/// Carries its own narrow `BlocSelector` on just whether the current
/// tab's filter is active (rule 9) — the title never rebuilds for it.
class MyListTopBar extends StatelessWidget {
  const MyListTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(context.l10n.navTabMyList, style: AppTextStyles.h2),
          // `null` on the People tab, which has nothing to filter.
          BlocSelector<MyListCubit, MyListFilterState, bool?>(
            selector: (state) =>
                state.showsPeople ? null : !state.currentFilter.isDefault,
            builder: (context, isActive) {
              if (isActive == null) {
                // Keeps the bar's height, so the page doesn't jump.
                return const SizedBox(height: kMinInteractiveDimension);
              }
              return IconButton(
                onPressed: () => _openFilterSheet(context),
                icon: Icon(
                  AppIcons.filter,
                  color: isActive ? AppColors.accent : AppColors.ink,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // showModalBottomSheet's builder gets a context under the Navigator,
  // a sibling of this page's own subtree — it does NOT see this page's
  // BlocProvider by default, so the same MyListCubit instance has to be
  // handed down explicitly via BlocProvider.value.
  void _openFilterSheet(BuildContext context) {
    final cubit = context.read<MyListCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          BlocProvider.value(value: cubit, child: const MyListFilterSheet()),
    );
  }
}
