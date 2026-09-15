import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di.dart';
import '../../../../core/domain/repositories/media_repository.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../cubit/my_list_cubit.dart';
import '../widgets/my_list_body.dart';
import '../widgets/my_list_segmented_tabs.dart';
import '../widgets/my_list_top_bar.dart';

/// My List (B4).
///
/// Implements `docs/SCREENS.md` B4.
///
/// Thin per CLAUDE.md rule 11: this file only provides [MyListCubit] and
/// assembles the sub-widgets in `../widgets/` — each of those already
/// carries its own rebuild-granularity rationale (rule 9); this file has
/// no `BlocBuilder`/`StreamBuilder` of its own.
class MyListScreen extends StatelessWidget {
  const MyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MyListCubit(),
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const MyListTopBar(),
              MyListSegmentedTabs(
                userLibraryRepository: getIt<UserLibraryRepository>(),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: MyListBody(
                  mediaRepository: getIt<MediaRepository>(),
                  userLibraryRepository: getIt<UserLibraryRepository>(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
