import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/library_tab_localization.dart';
import '../../../../shared/widgets/app_segmented_control.dart';
import '../cubit/my_list_cubit.dart';

/// B4's segmented Favorites · Watch later · Watched · People, as the app's
/// [AppSegmentedControl]. Only which tab is selected changes here (it comes
/// from [MyListCubit]); the labels carry no counts.
///
/// A segment is a [LibraryTab], or `null` for People (the one tab that isn't a
/// library tab).
class MyListTabs extends StatelessWidget {
  const MyListTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<MyListCubit>();
    return BlocSelector<MyListCubit, MyListFilterState, LibraryTab?>(
      selector: (state) => state.showsPeople ? null : state.tab,
      builder: (context, selected) => AppSegmentedControl<LibraryTab?>(
        segments: [
          for (final tab in LibraryTab.values)
            AppSegment(value: tab, label: tab.localizedLabel(l10n)),
          AppSegment(value: null, label: l10n.myListTabPeople),
        ],
        selected: selected,
        onSelected: (tab) =>
            tab == null ? cubit.selectPeople() : cubit.selectTab(tab),
      ),
    );
  }
}
