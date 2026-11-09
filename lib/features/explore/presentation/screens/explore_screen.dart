import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di.dart';
import '../../../../app/router.dart';
import '../../../../core/domain/repositories/media_repository.dart';
import '../../../../core/domain/repositories/settings_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/search_history_repository.dart';
import '../cubit/explore_cubit.dart';
import '../cubit/explore_state.dart';
import '../widgets/explore_content.dart';
import '../widgets/explore_header.dart';

/// Explore (B2) — `docs/SCREENS.md` B2.
///
/// Thin per CLAUDE.md rule 11: provides the Cubit and assembles
/// `ExploreHeader`/`ExploreContent`, each carrying its own
/// rebuild-granularity rationale (CLAUDE.md rule 9) in its own doc
/// comment.
class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExploreCubit(
        getIt<MediaRepository>(),
        getIt<SearchHistoryRepository>(),
        getIt<SettingsRepository>(),
      ),
      child: const _ExploreView(),
    );
  }
}

class _ExploreView extends StatelessWidget {
  const _ExploreView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExploreCubit, ExploreState>(
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
      child: const Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Column(
            children: [
              ExploreHeader(),
              Expanded(child: ExploreContent()),
            ],
          ),
        ),
      ),
    );
  }
}
