import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/media_segment.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../recommendations/presentation/cubit/recommendations_cubit.dart';
import '../../../recommendations/presentation/widgets/recommendation_section_view.dart';
import '../cubit/discover_cubit.dart';
import 'discover_hero.dart';
import 'discover_search_field.dart';
import 'discover_section_carousel.dart';

/// The hero + every section, once `DiscoverCubit` has something loaded
/// for [segment]. Only lays things out — [DiscoverHero] and
/// [DiscoverSectionCarousel] each independently select their own slice of
/// state, so this widget itself carries no Bloc subscription of its own
/// for `DiscoverCubit`'s own 8 named carousels; [RecommendationSectionView]
/// does the same for `RecommendationsCubit`'s own 2 (`docs/DECISIONS.md`
/// F1b).
///
/// "For you"/"Because you like X" render first, before every one of
/// `DiscoverCubit.sectionsBySegment`'s own named carousels, in every
/// segment — a deliberate simplification of the "All" segment's
/// original documented order (For You · Popular this week · Because you
/// like X · Watch later, interleaved) now that the same two sections
/// also show in Movies/TV Shows, which never had a documented order at
/// all. See `docs/SCREENS.md` B1.
class DiscoverContentLoaded extends StatelessWidget {
  const DiscoverContentLoaded({super.key, required this.segment});

  final MediaSegment segment;

  @override
  Widget build(BuildContext context) {
    final sections = DiscoverCubit.sectionsBySegment[segment]!;
    return RefreshIndicator(
      onRefresh: () => Future.wait([
        context.read<DiscoverCubit>().loadDiscover(segment),
        context.read<RecommendationsCubit>().refresh(),
      ]),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        children: [
          DiscoverHero(segment: segment),
          const SizedBox(height: AppSpacing.xl),
          const DiscoverSearchField(),
          // Each section below owns its own gap above it.
          RecommendationSectionView(
            slot: RecommendationSlot.forYou,
            segment: segment,
          ),
          RecommendationSectionView(
            slot: RecommendationSlot.becauseYouLike,
            segment: segment,
          ),
          for (final section in sections)
            DiscoverSectionCarousel(segment: segment, section: section),
          const SizedBox(height: AppSpacing.sectionGap),
        ],
      ),
    );
  }
}
