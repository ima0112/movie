import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di.dart';
import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/media_segment.dart';
import '../../../../core/domain/repositories/media_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/app_tab_bar.dart';
import '../../../../shared/widgets/match_fab.dart';
import '../../../../shared/widgets/media_card.dart';
import '../../../../shared/widgets/media_carousel.dart';
import '../../../../shared/widgets/state_views.dart';
import '../bloc/discover_cubit.dart';
import '../bloc/saved_ids_cubit.dart';

/// Discover (B1) — the app's home screen.
///
/// Source of truth: `docs/SCREENS.md` B1.
///
/// ## Rebuild granularity (CLAUDE.md rule 9)
///
/// Every independently-changing piece of this screen has its own narrowly
/// scoped builder — see each private widget's doc comment below for the
/// specific reason, but in summary:
/// - [_DiscoverHalo], [_TopBar], and [_DiscoverBottomBar] are `const` and
///   sit outside every `BlocBuilder`/`BlocSelector` — they never depend
///   on load state at all.
/// - [_SegmentedControl] reacts to `_DiscoverViewState`'s own local
///   `_segment` field (plain `setState`), not to `DiscoverCubit` — it
///   updates instantly on tap, before `loadDiscover` even resolves.
/// - [_ContentArea] is the *only* `BlocBuilder` scoped to "is Discover
///   loading, errored, or loaded" — and its `buildWhen` ignores emissions
///   for a segment other than the one currently selected, so a stale
///   in-flight request for a segment the user has since switched away
///   from can't cause a spurious rebuild here.
/// - [_HeroSection] and [_SectionCarousel] each carry their own
///   `BlocSelector` reading just their own slice of `DiscoverLoaded`
///   (`heroItems`, or `carousels[section]`). Today `DiscoverCubit` still
///   emits hero+all sections together in one `DiscoverLoaded`, so on the
///   very first load every selector happens to fire at once — but the
///   structure itself doesn't assume that: if a future `DiscoverCubit`
///   only updated one section, every other section's selector would see
///   an unchanged value and skip rebuilding. That's also why each
///   section's own skeleton/empty rendering lives inside its selector
///   rather than in one shared switch in `_ContentArea`.
/// - [_HeroSaveButton] carries its own `BlocSelector<SavedIdsCubit, ...>`
///   scoped to a single item id. Tapping one hero card's save button
///   only rebuilds that 36 px circle — never the card, never the hero
///   carousel, never the rest of the screen.
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

class _DiscoverView extends StatefulWidget {
  const _DiscoverView();

  @override
  State<_DiscoverView> createState() => _DiscoverViewState();
}

class _DiscoverViewState extends State<_DiscoverView> {
  // Local widget state, per the task: the segmented control reflects this
  // immediately on tap, without waiting for DiscoverCubit's Loading state
  // to come back around — it only ever *triggers* a load.
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
          const Positioned(left: 0, right: 0, top: 0, child: _DiscoverHalo()),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const _TopBar(),
                _SegmentedControl(
                  segment: _segment,
                  onSelected: _onSegmentSelected,
                ),
                const SizedBox(height: AppSpacing.lg),
                // Only this part shows a skeleton while loading — the
                // halo, top bar, segmented control, and bottom bar above
                // and below it are untouched.
                Expanded(child: _ContentArea(segment: _segment)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const _DiscoverBottomBar(),
    );
  }
}

/// Fixed amber halo behind the header and hero top — see
/// `docs/DESIGN_SYSTEM.md` section 1 ("Halo"). `const`, built once: it
/// never depends on load state.
///
/// TODO: SCREENS.md B1 also has this "fade with scrolling" — that needs a
/// `ScrollController` wired up from `_ContentLoaded`'s `ListView`, which
/// is out of scope for this pass (about rebuild granularity, not scroll
/// motion).
class _DiscoverHalo extends StatelessWidget {
  const _DiscoverHalo();

  // No token or SCREENS.md literal fixes this — it's a rough "how far
  // down the glow reaches" placement, not a design-system dimension.
  static const double _height = 420;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        height: _height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.1,
              colors: [AppColors.accentDeep, AppColors.surface],
            ),
          ),
        ),
      ),
    );
  }
}

/// "PakoTV" wordmark + search icon. `const`, built once: static structure
/// per `docs/SCREENS.md` B1 ("Top bar... Nothing else").
class _TopBar extends StatelessWidget {
  const _TopBar();

  // docs/SCREENS.md B1: "'PakoTV' wordmark at 24 px" — a one-off literal
  // for this specific brand mark (reuses h2's family/weight/line-height,
  // only the size is different), not a new entry in the general type
  // scale.
  static final TextStyle _wordmarkStyle = AppTextStyles.h2.copyWith(
    fontSize: 24,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Pako',
                  style: _wordmarkStyle.copyWith(color: AppColors.ink),
                ),
                TextSpan(
                  text: 'TV',
                  style: _wordmarkStyle.copyWith(color: AppColors.accent),
                ),
              ],
            ),
          ),
          IconButton(
            // TODO: → B2 (Explore) with the field focused, once go_router
            // and B2 exist.
            onPressed: () {},
            icon: const Icon(AppIcons.search, color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}

/// All | Movies | TV Shows. Driven entirely by [segment] and [onSelected]
/// — [_DiscoverViewState] owns the actual selection as local `setState`
/// (see the class doc on [DiscoverScreen]), so this widget has no idea
/// `DiscoverCubit` even exists.
class _SegmentedControl extends StatelessWidget {
  const _SegmentedControl({required this.segment, required this.onSelected});

  final MediaSegment segment;
  final ValueChanged<MediaSegment> onSelected;

  static const Duration _crossFade = Duration(milliseconds: 200);

  static const _labels = {
    MediaSegment.all: 'All',
    MediaSegment.movie: 'Movies',
    MediaSegment.tvShow: 'TV Shows',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: [
          for (final value in MediaSegment.values)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: GestureDetector(
                onTap: () => onSelected(value),
                child: AnimatedContainer(
                  duration: _crossFade,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: value == segment
                        ? AppColors.ink
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  child: AnimatedDefaultTextStyle(
                    duration: _crossFade,
                    style: AppTextStyles.bodySm.copyWith(
                      color: value == segment
                          ? AppColors.surface
                          : AppColors.inkMuted,
                    ),
                    child: Text(_labels[value]!),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The only `BlocBuilder` on this screen scoped to "is Discover loading,
/// errored, or loaded" — everything above it (halo, top bar, segmented
/// control) and below it (bottom bar) is untouched by this. See the class
/// doc on [DiscoverScreen] for the full rationale.
class _ContentArea extends StatelessWidget {
  const _ContentArea({required this.segment});

  final MediaSegment segment;

  /// A state is only relevant to this widget if it's [DiscoverInitial]
  /// (nothing has loaded for *any* segment yet) or it's about the
  /// currently-selected [segment] specifically. This is what lets
  /// `buildWhen` ignore a stale in-flight request for a segment the user
  /// has since switched away from.
  bool _isRelevant(DiscoverState state) => switch (state) {
    DiscoverInitial() => true,
    DiscoverLoading(:final segment) => segment == this.segment,
    DiscoverLoaded(:final segment) => segment == this.segment,
    DiscoverError(:final segment) => segment == this.segment,
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiscoverCubit, DiscoverState>(
      buildWhen: (previous, current) => _isRelevant(current),
      builder: (context, state) {
        if (!_isRelevant(state)) {
          return _ContentSkeleton(segment: segment);
        }
        return switch (state) {
          DiscoverInitial() => _ContentSkeleton(segment: segment),
          DiscoverLoading() => _ContentSkeleton(segment: segment),
          DiscoverError() => _ContentError(
            onRetry: () => context.read<DiscoverCubit>().loadDiscover(segment),
          ),
          DiscoverLoaded() => _ContentLoaded(segment: segment),
        };
      },
    );
  }
}

/// Skeleton for the whole content area — the hero plus one
/// [_SectionSkeleton] per section [segment] has, so switching segments
/// immediately shows the right *shape* of skeleton even before
/// `DiscoverCubit.sectionsBySegment` data arrives.
class _ContentSkeleton extends StatelessWidget {
  const _ContentSkeleton({required this.segment});

  final MediaSegment segment;

  @override
  Widget build(BuildContext context) {
    final sectionCount = DiscoverCubit.sectionsBySegment[segment]!.length;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: LayoutBuilder(
            builder: (context, constraints) => SkeletonBlock(
              width: constraints.maxWidth,
              height: MediaCardSize.hero.height,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),
        for (var i = 0; i < sectionCount; i++) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: _SectionSkeleton(),
          ),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ],
    );
  }
}

/// One section's skeleton: a title-shaped block, then a row of
/// carousel-poster-shaped blocks. Reused both by [_ContentSkeleton] (the
/// very first load) and by [_SectionCarousel] (a section that hasn't
/// arrived yet, once sections can load independently).
class _SectionSkeleton extends StatelessWidget {
  const _SectionSkeleton();

  static const int _posterCount = 3;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonBlock(width: 140, height: 20),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: MediaCardSize.carousel.height,
          child: Row(
            children: [
              for (var i = 0; i < _posterCount; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.md),
                SkeletonBlock(
                  width: MediaCardSize.carousel.width,
                  height: MediaCardSize.carousel.height,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Compact inline error, matching `docs/SCREENS.md` B1's per-section
/// error style literally ("90 px row 'Couldn't load · Retry'") — no Pako
/// here, that's reserved for empty/cold-start states elsewhere on this
/// screen (see B1: "This is the only place in Home where Pako appears",
/// referring to the cold-start invitation card, not a load error).
///
/// Used today for the *whole* content area, because `DiscoverCubit` loads
/// hero+sections atomically — a real failure fails everything at once.
/// Once sections can fail independently, this same widget is what
/// [_SectionCarousel] would show for just its own section.
class _ContentError extends StatelessWidget {
  const _ContentError({required this.onRetry});

  final VoidCallback onRetry;

  // Literal from docs/SCREENS.md ("90 px row"), not an AppSpacing token —
  // a fixed size of this one component.
  static const double _height = 90;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Couldn't load",
              style: AppTextStyles.body.copyWith(color: AppColors.inkMuted),
            ),
            const SizedBox(width: AppSpacing.sm),
            TextLinkButton(label: 'Retry', onTap: onRetry, fullWidth: false),
          ],
        ),
      ),
    );
  }
}

/// The hero + every section, once [DiscoverCubit] has something loaded
/// for [segment]. Only lays things out — [_HeroSection] and
/// [_SectionCarousel] each independently select their own slice of state
/// below.
class _ContentLoaded extends StatelessWidget {
  const _ContentLoaded({required this.segment});

  final MediaSegment segment;

  @override
  Widget build(BuildContext context) {
    final sections = DiscoverCubit.sectionsBySegment[segment]!;
    return RefreshIndicator(
      onRefresh: () => context.read<DiscoverCubit>().loadDiscover(segment),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        children: [
          _HeroSection(segment: segment),
          const SizedBox(height: AppSpacing.xxxl),
          for (final section in sections) ...[
            _SectionCarousel(segment: segment, section: section),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ],
      ),
    );
  }
}

/// The Discover hero. Carries its own `BlocSelector` on just
/// [DiscoverLoaded.heroItems] for [segment] — if a future `DiscoverCubit`
/// updated only a section's carousel, this selector's value wouldn't
/// change and the hero wouldn't rebuild.
class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.segment});

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
          saveButtonBuilder: (item) => _HeroSaveButton(itemId: item.id),
        );
      },
    );
  }
}

/// One hero card's save button. Carries its own `BlocSelector` scoped to
/// a single item id — tapping it (or another card's) only rebuilds this
/// 36 px circle, never the card it sits on or the hero carousel around
/// it. This is the piece the task called out explicitly: without a
/// per-item selector like this, the only way to reflect "is this item
/// saved" would be a `BlocBuilder` wrapping the whole hero (or worse, the
/// whole screen) — exactly what CLAUDE.md rule 9 forbids.
class _HeroSaveButton extends StatelessWidget {
  const _HeroSaveButton({required this.itemId});

  final int itemId;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SavedIdsCubit, Set<int>, bool>(
      selector: (savedIds) => savedIds.contains(itemId),
      builder: (context, isSaved) {
        return MediaCardSaveButton(
          isSaved: isSaved,
          onTap: () => context.read<SavedIdsCubit>().toggle(itemId),
        );
      },
    );
  }
}

/// One named carousel (see `docs/SCREENS.md` B1's per-segment section
/// lists). Carries its own `BlocSelector` on just
/// `DiscoverLoaded.carousels[section]` — the structure a future
/// per-section-loading `DiscoverCubit` needs: an unaffected section's
/// selected value stays equal across emissions, so only the section that
/// actually changed rebuilds. Renders its own [_SectionSkeleton] while
/// that value is still `null` for this segment.
class _SectionCarousel extends StatelessWidget {
  const _SectionCarousel({required this.segment, required this.section});

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
              ? const _SectionSkeleton()
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
/// [_SectionCarousel]'s `BlocSelector` builder, not behind a selector of
/// its own, since it never varies independently of that section's items.
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

/// Tab bar + Match FAB. `const`, built once — this is the same static
/// structure on every one of the four root screens, per
/// `docs/SCREENS.md` section B; it doesn't depend on Discover's load
/// state at all.
class _DiscoverBottomBar extends StatelessWidget {
  const _DiscoverBottomBar();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        const AppTabBar(activeTab: AppTab.discover),
        MatchFab(
          // TODO: → B3 (Match hub modal) once it exists.
          onTap: () {},
        ),
      ],
    );
  }
}
