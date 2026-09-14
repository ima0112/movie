import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di.dart';
import '../../../../core/domain/entities/media_segment.dart';
import '../../../../core/domain/repositories/media_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../bloc/discover_cubit.dart';
import '../bloc/saved_ids_cubit.dart';
import '../widgets/discover_content_area.dart';
import '../widgets/discover_halo.dart';
import '../widgets/discover_segmented_control.dart';
import '../widgets/discover_top_bar.dart';

/// Discover (B1) — the app's home screen.
///
/// Source of truth: `docs/SCREENS.md` B1.
///
/// Thin per CLAUDE.md rule 11: this file only provides the Cubits and
/// assembles the sub-widgets in `../widgets/`. Each of those carries its
/// own rebuild-granularity rationale (CLAUDE.md rule 9) in its own doc
/// comment — see, in particular, `DiscoverContentArea` (the only
/// `BlocBuilder` on the whole screen), `DiscoverHero` /
/// `DiscoverSectionCarousel` (their own `BlocSelector` per data slice),
/// and `DiscoverHeroSaveButton` (its own `BlocSelector` per item id).
class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              DiscoverCubit(getIt<MediaRepository>())
                ..loadDiscover(MediaSegment.all),
        ),
        BlocProvider(create: (_) => SavedIdsCubit()),
      ],
      child: const _DiscoverView(),
    );
  }
}

/// Owns the one piece of screen-level state that isn't a Cubit: which
/// segment is selected. See `DiscoverSegmentedControl`'s doc comment for
/// why this is local `setState` rather than `DiscoverCubit` state.
class _DiscoverView extends StatefulWidget {
  const _DiscoverView();

  @override
  State<_DiscoverView> createState() => _DiscoverViewState();
}

class _DiscoverViewState extends State<_DiscoverView> {
  MediaSegment _segment = MediaSegment.all;

  void _onSegmentSelected(MediaSegment segment) {
    if (segment == _segment) return;
    setState(() => _segment = segment);
    context.read<DiscoverCubit>().loadDiscover(segment);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          const Positioned(left: 0, right: 0, top: 0, child: DiscoverHalo()),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const DiscoverTopBar(),
                DiscoverSegmentedControl(
                  segment: _segment,
                  onSelected: _onSegmentSelected,
                ),
                const SizedBox(height: AppSpacing.lg),
                // Only this part shows a skeleton while loading — the
                // halo, top bar, and segmented control above it are
                // untouched. The tab bar + Match FAB now live in
                // `app/root_shell.dart`, shared by all four root tabs.
                Expanded(child: DiscoverContentArea(segment: _segment)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
