import 'package:flutter/material.dart';

import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/media_card.dart';

/// C1's "3-column grid with infinite scroll" (`docs/SCREENS.md` C1).
///
/// Reuses `MediaCard` at its `MediaCardSize.grid` variant — the fluid
/// 2:3 poster card `docs/DESIGN_SYSTEM.md` section 5 already calls for
/// ("grid (2:3 fluido)") but that no screen had built yet, added
/// alongside this file. Same bare-poster-plus-"TV"-tag look as the
/// carousel size: no title/metadata text under the poster, matching
/// `docs/SCREENS.md` J.2's own "Poster card (grid) with a 'TV' tag" —
/// nothing there about showing a title.
///
/// Pure presentation — no Cubit access. [items] is whatever's currently
/// visible (`FilteredListLoaded.visibleItems`); [onLoadMore] fires once
/// the user scrolls near the bottom, a no-op call when `!hasMore` is the
/// caller's job to guard the same way `FilteredListCubit.loadMore()`
/// already guards itself.
class FilteredListGrid extends StatefulWidget {
  const FilteredListGrid({
    super.key,
    required this.items,
    required this.hasMore,
    required this.onLoadMore,
    required this.onTap,
  });

  final List<MediaItem> items;
  final bool hasMore;
  final VoidCallback onLoadMore;
  final ValueChanged<MediaItem> onTap;

  static const int _crossAxisCount = 3;

  // How close to the bottom (in pixels) triggers the next page — same
  // idea as a typical infinite-scroll threshold, not a documented value.
  static const double _loadMoreThreshold = 200;

  @override
  State<FilteredListGrid> createState() => _FilteredListGridState();
}

class _FilteredListGridState extends State<FilteredListGrid> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!widget.hasMore) return;
    final position = _scrollController.position;
    if (position.pixels >=
        position.maxScrollExtent - FilteredListGrid._loadMoreThreshold) {
      widget.onLoadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppSpacing.xl),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: FilteredListGrid._crossAxisCount,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: MediaCardSize.grid.aspectRatio!,
      ),
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final item = widget.items[index];
        return MediaCard(
          size: MediaCardSize.grid,
          title: item.title,
          posterUrl: item.posterUrl,
          showTypeTag: item.type == MediaType.tvShow,
          onTap: () => widget.onTap(item),
        );
      },
    );
  }
}
