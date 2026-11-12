import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_tab_bar.dart';
import '../../../../shared/widgets/lazy_load.dart';
import '../../../../shared/widgets/media_card.dart';
import '../../domain/listing_style.dart';
import '../cubit/section_listing_cubit.dart';
import '../cubit/section_listing_state.dart';
import 'listing_poster.dart';

/// The 3-column grid of a loaded listing. **Pages in on demand** (CLAUDE.md
/// rule 17): a footer wrapped in `LazyLoad` asks the cubit for the next page
/// once it is within about a screen of the viewport, and again after every page
/// that arrives (its `loadKey` is the page number) — including when the first
/// page doesn't fill the screen. Pull to refresh starts over. [style] is the
/// section's own dressing; the current sort may swap it (`listingStyleFor`).
class ListingGrid extends StatelessWidget {
  const ListingGrid({
    super.key,
    required this.state,
    required this.style,
    required this.showPlatform,
  });

  final SectionListingLoaded state;
  final ListingStyle style;

  /// Each poster shows the platform it streams on (top-right).
  final bool showPlatform;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SectionListingCubit>();
    final dressing = listingStyleFor(state.sort, style);
    return RefreshIndicator(
      onRefresh: cubit.refresh,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenMargin,
              AppSpacing.lg,
              AppSpacing.screenMargin,
              0,
            ),
            sliver: SliverGrid.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: MediaCardSize.grid.aspectRatio!,
              ),
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final item = state.items[index];
                return ListingPoster(
                  key: ValueKey(item.key),
                  item: item,
                  style: dressing,
                  rank: index + 1,
                  showPlatform: showPlatform,
                  onTap: () => context.pushMediaDetail(item.key),
                );
              },
            ),
          ),
          SliverToBoxAdapter(child: _Footer(state: state)),
          SliverToBoxAdapter(
            child: SizedBox(height: AppTabBar.scrollInset(context)),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.state});

  final SectionListingLoaded state;

  static const double _height = 72;

  @override
  Widget build(BuildContext context) {
    if (!state.hasMore) return const SizedBox.shrink();
    final cubit = context.read<SectionListingCubit>();
    if (state.moreFailed) {
      return SizedBox(
        height: _height,
        child: Center(
          child: TextButton.icon(
            onPressed: cubit.retryMore,
            icon: const Icon(AppIcons.retry, color: AppColors.accent),
            label: Text(
              context.l10n.sectionListingLoadMoreFailed,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.accent),
            ),
          ),
        ),
      );
    }
    return LazyLoad(
      loadKey: state.page,
      onNear: cubit.loadMore,
      child: const SizedBox(
        height: _height,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
    );
  }
}
