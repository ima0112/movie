import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/media_segment.dart';
import '../../../../core/domain/repositories/media_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/media_carousel.dart';
import '../bloc/discover_cubit.dart';
import 'discover_section_skeleton.dart';

/// One named carousel (see `docs/SCREENS.md` B1's per-segment section
/// lists). Carries its own `BlocSelector` on just
/// `DiscoverLoaded.carousels[section]` — the structure a future
/// per-section-loading `DiscoverCubit` needs: an unaffected section's
/// selected value stays equal across emissions, so only the section that
/// actually changed rebuilds (CLAUDE.md rule 9). Renders its own
/// [DiscoverSectionSkeleton] while that value is still `null` for this
/// segment.
class DiscoverSectionCarousel extends StatelessWidget {
  const DiscoverSectionCarousel({
    super.key,
    required this.segment,
    required this.section,
  });

  final MediaSegment segment;
  final CarouselSection section;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<DiscoverCubit, DiscoverState, List<MediaItem>?>(
      selector: (state) {
        if (state is DiscoverLoaded && state.segment == segment) {
          return state.carousels[section];
        }
        return null;
      },
      builder: (context, items) {
        if (items != null && items.isEmpty) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: items == null
              ? const DiscoverSectionSkeleton()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(section: section),
                    const SizedBox(height: AppSpacing.md),
                    MediaCarousel.standard(
                      items: items,
                      // TV posters carry a "TV" pill only in the mixed
                      // "All" segment — see docs/SCREENS.md B1.
                      showTypeTag: segment == MediaSegment.all,
                    ),
                  ],
                ),
        );
      },
    );
  }
}

/// A section's "20/500 header + amber 14 px 'See all'" — see
/// `docs/SCREENS.md` B1. Static once its data has arrived — lives inside
/// [DiscoverSectionCarousel]'s `BlocSelector` builder, not behind a
/// selector of its own, since it never varies independently of that
/// section's items and is only ever used from there.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.section});

  final CarouselSection section;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(_sectionLabel(section), style: AppTextStyles.h2),
        GestureDetector(
          // TODO: → C1 (Filtered listing) once it and go_router exist.
          onTap: () {},
          child: Text(
            'See all',
            style: AppTextStyles.body.copyWith(color: AppColors.accent),
          ),
        ),
      ],
    );
  }
}

String _sectionLabel(CarouselSection section) => switch (section) {
  CarouselSection.forYou => 'For You',
  CarouselSection.popularThisWeek => 'Popular this week',
  CarouselSection.becauseYouLike => 'Because you like…',
  CarouselSection.watchLater => 'Watch later',
  CarouselSection.inTheaters => 'In theaters',
  CarouselSection.trending => 'Trending',
  CarouselSection.topRated => 'Top rated',
  CarouselSection.upcoming => 'Upcoming',
  CarouselSection.airingNow => 'Airing now',
  CarouselSection.popular => 'Popular',
};
