import 'package:flutter/material.dart';

import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/result_poster_tile.dart';
import '../../../../shared/widgets/results_grid.dart';

/// C1's 3-column grid with infinite scroll (`docs/SCREENS.md` C1): each tile is a
/// [ResultPosterTile] — poster, rating badge, "TV" tag and the title under it —
/// in the app's one results layout ([ResultsGrid]).
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
    final caption = ResultsGrid.captionExtent(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth - AppSpacing.screenMargin * 2;
        return GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenMargin,
            AppSpacing.lg,
            AppSpacing.screenMargin,
            AppSpacing.xl,
          ),
          gridDelegate: ResultsGrid.delegate(width, captionExtent: caption),
          itemCount: widget.items.length,
          itemBuilder: (context, index) {
            final item = widget.items[index];
            return ResultPosterTile(
              key: ValueKey(item.key),
              item: item,
              onTap: () => widget.onTap(item),
            );
          },
        );
      },
    );
  }
}
