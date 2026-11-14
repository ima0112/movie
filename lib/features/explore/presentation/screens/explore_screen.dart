import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/widgets/offline_banner_slot.dart';
import '../../../../app/di.dart';
import '../../../../app/router.dart';
import '../../../../core/domain/entities/media_segment.dart';
import '../../../../core/domain/repositories/media_repository.dart';
import '../../../../core/domain/repositories/settings_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/search_history_repository.dart';
import '../cubit/explore_browse_cubit.dart';
import '../cubit/explore_cubit.dart';
import '../cubit/explore_state.dart';
import '../widgets/explore_content.dart';
import '../widgets/explore_recents_panel.dart';
import '../widgets/explore_header.dart';

/// Explore (B2) — `docs/SCREENS.md` B2.
///
/// Thin per CLAUDE.md rule 11: provides the Cubit and assembles
/// `ExploreSearchBar`/`ExploreSegmentedControl`/`ExploreContent` and the
/// recent searches panel, each carrying its own
/// rebuild-granularity rationale (CLAUDE.md rule 9) in its own doc
/// comment.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key, this.focusToken});

  /// A new value asks the search field to take focus (B1's search bar is a
  /// shortcut to it); `null` or an unchanged value does nothing.
  final String? focusToken;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  /// The search field's focus: the field takes it, and the at-rest body reads
  /// it to show the recent searches while the field is focused.
  final FocusNode _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ExploreCubit(
            getIt<MediaRepository>(),
            getIt<SearchHistoryRepository>(),
            getIt<SettingsRepository>(),
          ),
        ),
        // Browsing (pills + sections) and searching share only the segment.
        BlocProvider(
          create: (_) => ExploreBrowseCubit(
            getIt<MediaRepository>(),
            getIt<SettingsRepository>(),
          )..start(MediaSegment.all),
        ),
      ],
      child: _ExploreView(
        searchFocus: _searchFocus,
        focusToken: widget.focusToken,
      ),
    );
  }
}

class _ExploreView extends StatelessWidget {
  const _ExploreView({required this.searchFocus, this.focusToken});

  final FocusNode searchFocus;
  final String? focusToken;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // The segmented control lives in ExploreCubit; browsing follows it.
        BlocListener<ExploreCubit, ExploreState>(
          listenWhen: (previous, current) =>
              previous.segment != current.segment,
          // People has nothing to browse: the sections keep the last titles
          // segment, so coming back to it costs nothing.
          listener: (context, state) {
            if (state.segment == MediaSegment.person) return;
            context.read<ExploreBrowseCubit>().setSegment(state.segment);
          },
        ),
        BlocListener<ExploreCubit, ExploreState>(
          listenWhen: (previous, current) => current is ExploreListing,
          listener: (context, state) {
            final listing = state as ExploreListing;
            unawaited(
              context
                  .push<void>(
                    AppRoutes.filteredList,
                    extra: FilteredListRouteArgs(
                      filter: listing.filter,
                      title: listing.title,
                    ),
                  )
                  // B2 renders nothing for `ExploreListing` (see that state's
                  // own doc comment) — without resetting back to State 1 on
                  // return, the screen would just stay blank after C1 pops.
                  .then((_) {
                    if (context.mounted) {
                      context.read<ExploreCubit>().clearQuery();
                    }
                  }),
            );
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          // The root shell's floating bar is in the lists' own bottom padding.
          bottom: false,
          child: Column(
            children: [
              const OfflineBannerSlot(),
              ExploreSearchBar(
                searchFocus: searchFocus,
                focusToken: focusToken,
              ),
              // Everything under the field. The recent searches panel is the
              // last child: it drops from the field over the segmented control
              // and the page, using this area as its height budget.
              Expanded(
                child: Stack(
                  children: [
                    const Column(
                      children: [
                        ExploreSegmentedControl(),
                        Expanded(child: ExploreContent()),
                      ],
                    ),
                    Positioned.fill(
                      child: ExploreRecentsPanel(searchFocus: searchFocus),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
