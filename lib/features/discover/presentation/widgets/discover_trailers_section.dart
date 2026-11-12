import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/trailer_item.dart';
import '../../../../core/launch/launch_external_link.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_section.dart';
import '../../../../shared/widgets/lazy_load.dart';
import '../../../../shared/widgets/trailer_carousel.dart';
import '../cubit/discover_cubit.dart';
import 'discover_content_error.dart';
import 'discover_section_skeleton.dart';

/// B1's "Latest trailers" (All segment). **Loads on demand** like every
/// other Discover block: it needs one request per title, so it waits until
/// it nears the viewport. Its own `BlocSelector` on just the trailers slot.
/// Tapping a card opens the trailer in YouTube (no in-app playback).
class DiscoverTrailersSection extends StatelessWidget {
  const DiscoverTrailersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      DiscoverCubit,
      DiscoverState,
      DiscoverSlot<List<TrailerItem>>?
    >(
      selector: (state) => state is DiscoverLoaded ? state.trailers : null,
      builder: (context, slot) {
        final title = context.l10n.carouselSectionLatestTrailers;
        return LazyLoad(
          onNear: () => context.read<DiscoverCubit>().requestTrailers(),
          child: switch (slot) {
            null || DiscoverSlotLoading() => const AppSection(
              child: DiscoverSectionSkeleton(),
            ),
            DiscoverSlotError() => AppSection(
              title: title,
              child: DiscoverContentError(
                onRetry: () => context.read<DiscoverCubit>().retryTrailers(),
              ),
            ),
            DiscoverSlotLoaded(:final value) when value.isEmpty =>
              const SizedBox.shrink(),
            DiscoverSlotLoaded(:final value) => AppSection(
              title: title,
              child: TrailerCarousel(
                trailers: value,
                onTrailerTap: (trailer) =>
                    launchYoutubeTrailer(context, trailer.video.key),
              ),
            ),
          },
        );
      },
    );
  }
}
