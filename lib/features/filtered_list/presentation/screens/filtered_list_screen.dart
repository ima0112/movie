import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di.dart';
import '../../../../core/domain/entities/discover_filter.dart';
import '../../../../core/domain/repositories/settings_repository.dart';
import '../../../../core/domain/entities/country.dart';
import '../../../../core/domain/repositories/media_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../shared/widgets/explore_filter_sheet.dart';
import '../cubit/filtered_list_cubit.dart';
import '../cubit/filtered_list_state.dart';
import '../widgets/filtered_list_content.dart';

/// C1 (Filtered listing) — `docs/SCREENS.md` C1: "See all · Genre ·
/// Results", reached from B1's "See all", a B2 genre tile, or H8's "See
/// N results".
///
/// A pushed screen per the inventory's navigation rule ("Every pushed
/// screen... has a back button... and hides the bottom bar"): registered
/// on the root navigator in `app/router.dart`, outside `RootShell`'s four
/// tab branches, the same way `/movie/:id`/`/stats`/`/my-tastes` are.
///
/// Thin per CLAUDE.md rule 11: provides [FilteredListCubit] and assembles
/// the app bar + [FilteredListContent], each with its own
/// rebuild-granularity rationale (CLAUDE.md rule 9).
class FilteredListScreen extends StatelessWidget {
  const FilteredListScreen({
    super.key,
    required this.filter,
    required this.title,
    this.collectionSection,
  });

  final DiscoverFilter filter;
  final String title;
  final CarouselSection? collectionSection;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FilteredListCubit(
        getIt<MediaRepository>(),
        filter,
        collectionSection: collectionSection,
      )..load(),
      child: _FilteredListView(title: title),
    );
  }
}

class _FilteredListView extends StatelessWidget {
  const _FilteredListView({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(AppIcons.back, color: AppColors.ink),
          onPressed: () => context.pop(),
        ),
        title: Text(title),
        actions: [
          BlocSelector<FilteredListCubit, FilteredListState, bool>(
            selector: (state) => !state.filter.isDefault,
            builder: (context, isActive) => IconButton(
              icon: Icon(
                AppIcons.filter,
                color: isActive ? AppColors.accent : AppColors.ink,
              ),
              onPressed: () => _openFilterSheet(context),
            ),
          ),
        ],
      ),
      body: const FilteredListContent(),
    );
  }

  // showModalBottomSheet's builder gets a context under the Navigator, a
  // sibling of this page's own subtree — same reasoning as
  // `MyListTopBar._openFilterSheet`: the Cubit has to be handed down
  // explicitly rather than relied on to still be in scope.
  void _openFilterSheet(BuildContext context) {
    final cubit = context.read<FilteredListCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ExploreFilterSheet(
        initialFilter: cubit.state.filter,
        mediaRepository: getIt<MediaRepository>(),
        regionName: countryName(getIt<SettingsRepository>().current.regionCode),
        onApply: cubit.updateFilter,
      ),
    );
  }
}
