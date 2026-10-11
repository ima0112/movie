import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/filter_controls.dart';
import '../cubit/my_list_cubit.dart';
import 'my_list_filter_chips.dart';
import 'my_list_filter_toggles.dart';

/// H9 (Sort and filter My List) — `docs/SCREENS.md` H9.
///
/// Edits a local draft of the currently selected tab's [TabFilter];
/// nothing reaches [MyListCubit] until "Apply" is tapped, and swiping the
/// sheet closed (the framework's own bottom-sheet behavior) discards the
/// draft entirely — exactly H9's "swiping to close discards". "Reset"
/// only clears the draft back to defaults; it still needs "Apply" to
/// commit, same as any other change here.
class MyListFilterSheet extends StatefulWidget {
  const MyListFilterSheet({super.key});

  @override
  State<MyListFilterSheet> createState() => _MyListFilterSheetState();
}

class _MyListFilterSheetState extends State<MyListFilterSheet> {
  late final LibraryTab _tab;
  late TabFilter _draft;

  bool get _isWatched => _tab == LibraryTab.watched;

  static const _baseSorts = [
    MyListSort.titleAZ,
    MyListSort.year,
    MyListSort.tmdbRating,
  ];

  @override
  void initState() {
    super.initState();
    final state = context.read<MyListCubit>().state;
    _tab = state.tab;
    _draft = state.currentFilter;
  }

  void _update({
    MediaType? Function()? type,
    MyListSort? sort,
    int? Function()? minStars,
    bool? hideWatched,
  }) {
    setState(() {
      _draft = TabFilter(
        type: type == null ? _draft.type : type(),
        sort: sort ?? _draft.sort,
        minStars: minStars == null ? _draft.minStars : minStars(),
        hideWatched: hideWatched ?? _draft.hideWatched,
      );
    });
  }

  void _apply() {
    final cubit = context.read<MyListCubit>();
    cubit.selectType(_draft.type);
    cubit.selectSort(_draft.sort);
    if (_isWatched) {
      cubit.selectMinStars(_draft.minStars);
    } else {
      cubit.setHideWatched(_draft.hideWatched);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.myListFilterSheetTitle, style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.xl),
            FilterSectionLabel(l10n.filterSheetSectionType),
            TypeFilterChips(
              type: _draft.type,
              onChanged: (type) => _update(type: () => type),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilterSectionLabel(l10n.filterSheetSectionSortBy),
            SortFilterChips(
              options: [
                ..._baseSorts,
                if (_isWatched) ...[
                  MyListSort.myRating,
                  MyListSort.dateWatched,
                ],
              ],
              sort: _draft.sort,
              onChanged: (sort) => _update(sort: sort),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_isWatched) ...[
              FilterSectionLabel(l10n.filterSheetSectionMinRating),
              MinStarsFilterRow(
                minStars: _draft.minStars,
                onChanged: (minStars) => _update(minStars: () => minStars),
              ),
            ] else
              HideWatchedFilterRow(
                hideWatched: _draft.hideWatched,
                onChanged: (hideWatched) => _update(hideWatched: hideWatched),
              ),
            const SizedBox(height: AppSpacing.xxl),
            Row(
              children: [
                if (!_draft.isDefault) ...[
                  Expanded(
                    child: SecondaryButton(
                      label: l10n.commonReset,
                      onTap: () => setState(() => _draft = const TabFilter()),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                ],
                Expanded(
                  child: PrimaryButton(label: l10n.commonApply, onTap: _apply),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
