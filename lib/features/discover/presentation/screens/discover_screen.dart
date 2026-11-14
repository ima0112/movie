import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/widgets/offline_banner_slot.dart';
import '../../../../app/di.dart';
import '../../../../app/router.dart';
import '../../../../core/domain/entities/media_segment.dart';
import '../../../../core/domain/repositories/media_repository.dart';
import '../../../../core/domain/repositories/recently_viewed_repository.dart';
import '../../../../core/domain/repositories/settings_repository.dart';
import '../../../../core/domain/repositories/taste_profile_repository.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_halo.dart';
import '../../../../shared/widgets/media_segmented_control.dart';
import '../../../match_engine/domain/vibe_catalog.dart';
import '../../../recommendations/presentation/cubit/recommendations_cubit.dart';
import '../cubit/discover_cubit.dart';
import '../cubit/recently_viewed_cubit.dart';
import '../widgets/discover_content_area.dart';
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
/// `DiscoverHeroSaveButton` (its own `BlocSelector` per item id), and
/// `RecommendationSectionView` (its own, for `RecommendationsCubit`).
class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => DiscoverCubit(
            getIt<MediaRepository>(),
            getIt<SettingsRepository>(),
          )..loadDiscover(MediaSegment.all),
        ),
        BlocProvider(
          create: (_) => RecentlyViewedCubit(getIt<RecentlyViewedRepository>()),
        ),
        BlocProvider(
          create: (_) => RecommendationsCubit(
            getIt<MediaRepository>(),
            getIt<UserLibraryRepository>(),
            getIt<TasteProfileRepository>(),
            getIt<SettingsRepository>(),
            VibeCatalog.loadFromAssets(),
          )..load(MediaSegment.all),
        ),
      ],
      child: const _DiscoverView(),
    );
  }
}

/// Owns the one piece of screen-level state that isn't a Cubit: which
/// segment is selected. See `DiscoverSegmentedControl`'s doc comment for
/// why this is local `setState` rather than `DiscoverCubit` state.
///
/// [RouteAware] + `app/router.dart`'s own `discoverRouteObserver`:
/// `RecommendationsCubit.refresh()`'s own "returning from a pushed
/// detail screen" trigger (`docs/SCREENS.md` B1) — see that Cubit's own
/// doc comment for which 3 triggers exist and which don't.
class _DiscoverView extends StatefulWidget {
  const _DiscoverView();

  @override
  State<_DiscoverView> createState() => _DiscoverViewState();
}

class _DiscoverViewState extends State<_DiscoverView> with RouteAware {
  MediaSegment _segment = MediaSegment.all;

  void _onSegmentSelected(MediaSegment segment) {
    if (segment == _segment) return;
    setState(() => _segment = segment);
    context.read<DiscoverCubit>().loadDiscover(segment);
    context.read<RecommendationsCubit>().load(segment);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    discoverRouteObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void didPopNext() {
    context.read<RecommendationsCubit>().refresh();
  }

  @override
  void dispose() {
    discoverRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          const Positioned(left: 0, right: 0, top: 0, child: AppHalo()),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const DiscoverTopBar(),
                const OfflineBannerSlot(),
                MediaSegmentedControl(
                  // Floats over the halo: translucent, like the bottom bar.
                  glass: true,
                  segment: _segment,
                  onSelected: _onSegmentSelected,
                ),
                // The content area adds its own top gap (the fade's height).
                const SizedBox(height: AppSpacing.md),
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
