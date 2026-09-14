import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/media_segment.dart';
import '../../../../shared/widgets/media_carousel.dart';
import '../bloc/discover_cubit.dart';
import 'discover_hero_save_button.dart';

/// The Discover hero. Carries its own `BlocSelector` on just
/// `DiscoverLoaded.heroItems` for [segment] — if a future `DiscoverCubit`
/// updated only a section's carousel, this selector's value wouldn't
/// change and the hero wouldn't rebuild (CLAUDE.md rule 9).
class DiscoverHero extends StatelessWidget {
  const DiscoverHero({super.key, required this.segment});

  final MediaSegment segment;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<DiscoverCubit, DiscoverState, List<MediaItem>?>(
      selector: (state) {
        if (state is DiscoverLoaded && state.segment == segment) {
          return state.heroItems;
        }
        return null;
      },
      builder: (context, heroItems) {
        if (heroItems == null || heroItems.isEmpty) {
          // Not loaded (yet) for this segment, or genuinely empty. B1's
          // cold-start invitation card would go here, but that needs a
          // taste profile / My List signal this screen doesn't have
          // access to yet (no TasteProfileRepository/UserLibraryRepository).
          return const SizedBox.shrink();
        }
        return MediaCarousel.hero(
          items: heroItems,
          saveButtonBuilder: (item) =>
              DiscoverHeroSaveButton(itemId: item.id),
          // `push`, not `go`: the detail screen's back button should
          // return to Discover with its scroll position intact, not
          // replace it in the stack.
          onItemTap: (item) =>
              context.push(AppRoutes.movieDetail(item.id)),
        );
      },
    );
  }
}
