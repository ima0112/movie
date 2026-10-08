import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/user_media_entry.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/library_tab_localization.dart';
import '../cubit/my_list_cubit.dart';

/// B4's "Segmented Favorites · Watch later · Watched, each with a live
/// counter" (`docs/SCREENS.md` B4).
///
/// Which tab is selected comes from [MyListCubit]; each segment's own
/// *count* subscribes directly to `UserLibraryRepository.watch(tab:)`
/// instead — the Cubit never caches the list, so the count can't come
/// from it either (CLAUDE.md rule 10). Each segment is its own narrowly
/// scoped `BlocSelector` + `StreamBuilder` pair (rule 9): tapping one, or
/// a change in one tab's count, never rebuilds the other two.
class MyListSegmentedTabs extends StatelessWidget {
  const MyListSegmentedTabs({super.key, required this.userLibraryRepository});

  final UserLibraryRepository userLibraryRepository;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: [
          for (final tab in LibraryTab.values)
            Expanded(
              child: _Segment(
                tab: tab,
                label: tab.localizedLabel(l10n),
                userLibraryRepository: userLibraryRepository,
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.tab,
    required this.label,
    required this.userLibraryRepository,
  });

  final LibraryTab tab;
  final String label;
  final UserLibraryRepository userLibraryRepository;

  static const Duration _crossFade = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MyListCubit, MyListFilterState, bool>(
      selector: (state) => state.tab == tab,
      builder: (context, isSelected) {
        return GestureDetector(
          onTap: () => context.read<MyListCubit>().selectTab(tab),
          child: AnimatedContainer(
            duration: _crossFade,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.ink : Colors.transparent,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            ),
            child: StreamBuilder<List<UserMediaEntry>>(
              stream: userLibraryRepository.watch(tab: tab),
              builder: (context, snapshot) {
                final count = snapshot.data?.length ?? 0;
                return AnimatedDefaultTextStyle(
                  duration: _crossFade,
                  style: AppTextStyles.bodySm.copyWith(
                    color: isSelected ? AppColors.surface : AppColors.inkMuted,
                  ),
                  child: Text(
                    '$label ($count)',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
