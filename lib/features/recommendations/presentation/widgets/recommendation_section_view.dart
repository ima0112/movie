import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router.dart';
import '../../../../core/domain/entities/media_segment.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_section.dart';
import '../../../../shared/widgets/media_card.dart';
import '../../../../shared/widgets/media_carousel.dart';
import '../../../discover/presentation/widgets/discover_content_error.dart';
import '../../../discover/presentation/widgets/discover_section_skeleton.dart';
import '../../../../l10n/genre_localization.dart';
import '../../../../l10n/vibe_localization.dart';
import '../../domain/recommendation_planner.dart';
import '../cubit/recommendations_cubit.dart';

/// One of B1's "For you"/"Because you like X" sections — its own
/// `BlocSelector` on just [slot]'s own slot of [RecommendationsState],
/// for [segment] (CLAUDE.md rule 9: loading/erroring/retrying one never
/// touches the other, or the 8 sections `DiscoverCubit` owns). Renders
/// nothing at all for [RecommendationSectionHidden] — never an empty or
/// generic carousel (`docs/DECISIONS.md` F1b) — and nothing for a
/// segment other than the one currently selected (this widget is kept
/// in the tree for all 3 segments' own `DiscoverContentLoaded`, but only
/// the active one's own slot is ever non-null).
class RecommendationSectionView extends StatelessWidget {
  const RecommendationSectionView({
    super.key,
    required this.slot,
    required this.segment,
  });

  final RecommendationSlot slot;
  final MediaSegment segment;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      RecommendationsCubit,
      RecommendationsState,
      RecommendationSectionState?
    >(
      selector: (state) {
        if (state.segment != segment) return null;
        return state.slot(slot);
      },
      builder: (context, sectionState) {
        return switch (sectionState) {
          null || RecommendationSectionHidden() => const SizedBox.shrink(),
          RecommendationSectionLoading() => const AppSection(
            child: DiscoverSectionSkeleton(),
          ),
          RecommendationSectionError() => AppSection(
            child: DiscoverContentError(
              onRetry: () => context.read<RecommendationsCubit>().retry(slot),
            ),
          ),
          RecommendationSectionLoaded(:final items, :final seed) => AppSection(
            title: _header(context, seed),
            child: MediaCarousel.standard(
              items: items,
              // "For you" leads the page: larger than the "Because you…" ones.
              size: slot == RecommendationSlot.forYou
                  ? MediaCardSize.carouselLarge
                  : MediaCardSize.carousel,
              showTypeTag: segment == MediaSegment.all,
              onItemTap: (item) => context.pushMediaDetail(item.key),
            ),
          ),
        };
      },
    );
  }

  String _header(BuildContext context, BecauseSeed? seed) {
    final l10n = context.l10n;
    // A "Because you…" section always has its seed (the cubit sets it with
    // the loaded state); "For you" never does.
    return switch (seed) {
      null => l10n.carouselSectionForYou,
      TitleSeed(:final entry) => l10n.carouselSectionBecauseYouLike(
        entry.title,
      ),
      GenreSeed(:final genre) => l10n.carouselSectionBecauseYouLikeGenre(
        genre.localizedName(l10n),
      ),
      VibeSeed(:final vibe) => l10n.carouselSectionBecauseYouWantVibe(
        vibe.localizedName(l10n),
      ),
    };
  }
}
