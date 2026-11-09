import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/user_media_entry.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/library_tab_localization.dart';
import '../../../../shared/widgets/app_segmented_control.dart';
import '../cubit/my_list_cubit.dart';

/// B4's "Segmented Favorites · Watch later · Watched, each with a live
/// counter" (`docs/SCREENS.md` B4), as the app's [AppSegmentedControl].
///
/// Which tab is selected comes from [MyListCubit]; each segment's own
/// *count* subscribes directly to `UserLibraryRepository.watch(tab:)`
/// instead — the Cubit never caches the list, so the count can't come
/// from it either (CLAUDE.md rule 10). Each segment owns its own label
/// `StreamBuilder` (rule 9): a change in one tab's count never rebuilds the
/// other two. The streams are created once (this is stateful for that), so a
/// tab change doesn't resubscribe them.
class MyListTabs extends StatefulWidget {
  const MyListTabs({super.key, required this.userLibraryRepository});

  final UserLibraryRepository userLibraryRepository;

  @override
  State<MyListTabs> createState() => _MyListTabsState();
}

class _MyListTabsState extends State<MyListTabs> {
  late final Map<LibraryTab, Stream<List<UserMediaEntry>>> _entries = {
    for (final tab in LibraryTab.values)
      tab: widget.userLibraryRepository.watch(tab: tab).asBroadcastStream(),
  };
  final Map<LibraryTab, Stream<String>> _labels = {};

  Stream<String> _labelStream(LibraryTab tab, AppLocalizations l10n) {
    return _labels[tab] ??= _entries[tab]!
        .map(
          (entries) => l10n.myListSegmentLabelWithCount(
            tab.localizedLabel(l10n),
            entries.length,
          ),
        )
        .asBroadcastStream();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocSelector<MyListCubit, MyListFilterState, LibraryTab>(
      selector: (state) => state.tab,
      builder: (context, selected) => AppSegmentedControl<LibraryTab>(
        segments: [
          for (final tab in LibraryTab.values)
            AppSegment(
              value: tab,
              label: tab.localizedLabel(l10n),
              labelStream: _labelStream(tab, l10n),
            ),
        ],
        selected: selected,
        onSelected: context.read<MyListCubit>().selectTab,
      ),
    );
  }
}
