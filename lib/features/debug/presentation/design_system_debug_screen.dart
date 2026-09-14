import 'package:flutter/material.dart';

import '../../../core/domain/entities/media_item.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/app_tab_bar.dart';
import '../../../shared/widgets/genre_bar.dart';
import '../../../shared/widgets/library_row.dart';
import '../../../shared/widgets/match_fab.dart';
import '../../../shared/widgets/media_card.dart';
import '../../../shared/widgets/media_carousel.dart';
import '../../../shared/widgets/metric_card.dart';
import '../../../shared/widgets/pako_state.dart';
import '../../../shared/widgets/quiz_tile.dart';
import '../../../shared/widgets/state_views.dart';

/// Debug-only screen that renders every color, text style, and spacing
/// token so the design system tokens can be checked visually.
///
/// Not part of the product's screen inventory (`docs/SCREENS.md`) — this
/// exists purely to verify `core/theme/` before building real screens.
class DesignSystemDebugScreen extends StatelessWidget {
  const DesignSystemDebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Design system debug')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          _SectionTitle('Colors'),
          const SizedBox(height: AppSpacing.md),
          _ColorSection(),
          const SizedBox(height: AppSpacing.xxxl),
          _SectionTitle('Text styles'),
          const SizedBox(height: AppSpacing.md),
          const _TextStylesSection(),
          const SizedBox(height: AppSpacing.xxxl),
          _SectionTitle('Spacing'),
          const SizedBox(height: AppSpacing.md),
          const _SpacingSection(),
          const SizedBox(height: AppSpacing.xxxl),
          _SectionTitle('Icons'),
          const SizedBox(height: AppSpacing.md),
          const _IconsSection(),
          const SizedBox(height: AppSpacing.xxxl),
          _SectionTitle('Pako'),
          const SizedBox(height: AppSpacing.md),
          const _PakoSection(),
          const SizedBox(height: AppSpacing.xxxl),
          _SectionTitle('Media card'),
          const SizedBox(height: AppSpacing.md),
          const _MediaCardSection(),
          const SizedBox(height: AppSpacing.xxxl),
          _SectionTitle('Chip'),
          const SizedBox(height: AppSpacing.md),
          const _ChipSection(),
          const SizedBox(height: AppSpacing.xxxl),
          _SectionTitle('Quiz tile'),
          const SizedBox(height: AppSpacing.md),
          const _QuizTileSection(),
          const SizedBox(height: AppSpacing.xxxl),
          _SectionTitle('Buttons'),
          const SizedBox(height: AppSpacing.md),
          const _ButtonsSection(),
          const SizedBox(height: AppSpacing.xxxl),
          _SectionTitle('Tab bar + Match FAB'),
          const SizedBox(height: AppSpacing.md),
          const _TabBarSection(),
          const SizedBox(height: AppSpacing.xxxl),
          _SectionTitle('Metric card + genre bar'),
          const SizedBox(height: AppSpacing.md),
          const _StatsSection(),
          const SizedBox(height: AppSpacing.xxxl),
          _SectionTitle('Library row'),
          const SizedBox(height: AppSpacing.md),
          const _LibraryRowSection(),
          const SizedBox(height: AppSpacing.xxxl),
          _SectionTitle('State views'),
          const SizedBox(height: AppSpacing.md),
          const _StateViewsSection(),
          const SizedBox(height: AppSpacing.xxxl),
          _SectionTitle('Media carousel'),
          const SizedBox(height: AppSpacing.md),
          const _MediaCarouselSection(),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: AppTextStyles.h2);
  }
}

class _ColorSection extends StatelessWidget {
  const _ColorSection();

  static const _swatches = <(String, Color)>[
    ('surface', AppColors.surface),
    ('surfaceRaised', AppColors.surfaceRaised),
    ('surfaceRaised2', AppColors.surfaceRaised2),
    ('line', AppColors.line),
    ('lineStrong', AppColors.lineStrong),
    ('ink', AppColors.ink),
    ('inkMuted', AppColors.inkMuted),
    ('inkDim', AppColors.inkDim),
    ('accent', AppColors.accent),
    ('accentDeep', AppColors.accentDeep),
    ('onAccent', AppColors.onAccent),
    ('success', AppColors.success),
    ('danger', AppColors.danger),
    ('profileAmber', AppColors.profileAmber),
    ('profileCoral', AppColors.profileCoral),
    ('profileMint', AppColors.profileMint),
    ('profileLilac', AppColors.profileLilac),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        for (final (name, color) in _swatches) _ColorSwatch(name, color),
      ],
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch(this.name, this.color);

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 96,
            height: 64,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.lineStrong),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            name,
            style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
          ),
        ],
      ),
    );
  }
}

class _TextStylesSection extends StatelessWidget {
  const _TextStylesSection();

  static const _styles = <(String, TextStyle Function())>[
    ('display', _display),
    ('h1', _h1),
    ('h2', _h2),
    ('h3', _h3),
    ('body', _body),
    ('bodySm', _bodySm),
    ('caption', _caption),
    ('micro', _micro),
  ];

  static TextStyle _display() => AppTextStyles.display;
  static TextStyle _h1() => AppTextStyles.h1;
  static TextStyle _h2() => AppTextStyles.h2;
  static TextStyle _h3() => AppTextStyles.h3;
  static TextStyle _body() => AppTextStyles.body;
  static TextStyle _bodySm() => AppTextStyles.bodySm;
  static TextStyle _caption() => AppTextStyles.caption;
  static TextStyle _micro() => AppTextStyles.micro;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (name, styleBuilder) in _styles)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                SizedBox(
                  width: 64,
                  child: Text(
                    name,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.inkMuted,
                    ),
                  ),
                ),
                Expanded(
                  child: Text('PakoTV — Aa 0123', style: styleBuilder()),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SpacingSection extends StatelessWidget {
  const _SpacingSection();

  static const _tokens = <(String, double)>[
    ('xs', AppSpacing.xs),
    ('sm', AppSpacing.sm),
    ('md', AppSpacing.md),
    ('lg', AppSpacing.lg),
    ('xl', AppSpacing.xl),
    ('xxl', AppSpacing.xxl),
    ('xxxl', AppSpacing.xxxl),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (name, value) in _tokens)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                SizedBox(
                  width: 64,
                  child: Text(
                    '$name (${value.toInt()})',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.inkMuted,
                    ),
                  ),
                ),
                Container(
                  width: value,
                  height: AppSpacing.lg,
                  color: AppColors.accent,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _IconsSection extends StatelessWidget {
  const _IconsSection();

  static const _icons = <(String, IconData)>[
    ('search', AppIcons.search),
    ('filter', AppIcons.filter),
    ('favorite', AppIcons.favorite),
    ('favoriteFill', AppIcons.favoriteFill),
    ('watchLater', AppIcons.watchLater),
    ('watchLaterFill', AppIcons.watchLaterFill),
    ('watched', AppIcons.watched),
    ('watchedFill', AppIcons.watchedFill),
    ('play', AppIcons.play),
    ('share', AppIcons.share),
    ('back', AppIcons.back),
    ('close', AppIcons.close),
    ('home', AppIcons.home),
    ('compass', AppIcons.compass),
    ('user', AppIcons.user),
    ('settings', AppIcons.settings),
    ('stats', AppIcons.stats),
    ('qrCode', AppIcons.qrCode),
    ('copy', AppIcons.copy),
    ('retry', AppIcons.retry),
    ('check', AppIcons.check),
    ('chevronRight', AppIcons.chevronRight),
    ('chevronDown', AppIcons.chevronDown),
    ('info', AppIcons.info),
    ('hourglass', AppIcons.hourglass),
    ('group', AppIcons.group),
    ('dice', AppIcons.dice),
    ('useMyTastes', AppIcons.useMyTastes),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.lg,
      children: [
        for (final (name, icon) in _icons) _IconSwatch(name, icon),
      ],
    );
  }
}

class _IconSwatch extends StatelessWidget {
  const _IconSwatch(this.name, this.icon);

  final String name;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: Column(
        children: [
          Icon(icon, size: 24, color: AppColors.ink),
          const SizedBox(height: AppSpacing.xs),
          Text(
            name,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
          ),
        ],
      ),
    );
  }
}

class _PakoSection extends StatelessWidget {
  const _PakoSection();

  static const _moods = <(String, PakoMood)>[
    ('off', PakoMood.off),
    ('idle', PakoMood.idle),
    ('asleep', PakoMood.asleep),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (name, mood) in _moods)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xxl),
            child: Column(
              children: [
                PakoState(mood: mood, size: 80),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  name,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _MediaCardSection extends StatelessWidget {
  const _MediaCardSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Carousel (110×165)',
          style: AppTextStyles.h3.copyWith(color: AppColors.inkMuted),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            _Labeled(
              label: 'default',
              child: MediaCard(
                size: MediaCardSize.carousel,
                title: 'Dune: Part Two',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            _Labeled(
              label: 'TV tag',
              child: MediaCard(
                size: MediaCardSize.carousel,
                title: 'The Bear',
                showTypeTag: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          'Hero (330×440)',
          style: AppTextStyles.h3.copyWith(color: AppColors.inkMuted),
        ),
        const SizedBox(height: AppSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _Labeled(
                label: '"For you" tag + save',
                child: MediaCard(
                  size: MediaCardSize.hero,
                  title: 'Oppenheimer',
                  reasonTag: 'For you',
                  onSaveTap: () {},
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              _Labeled(
                label: 'TV tag + neutral reasonTag',
                child: MediaCard(
                  size: MediaCardSize.hero,
                  title: 'Fallout',
                  showTypeTag: true,
                  reasonTag: 'Popular this week',
                  onSaveTap: () {},
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              _Labeled(
                label: 'no tag, no save',
                child: MediaCard(size: MediaCardSize.hero, title: 'Poor Things'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Labeled extends StatelessWidget {
  const _Labeled({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        child,
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
        ),
      ],
    );
  }
}

class _ChipSection extends StatelessWidget {
  const _ChipSection();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.lg,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: [
        _Labeled(
          label: 'normal',
          child: AppChip(label: 'Comedy', onTap: () {}),
        ),
        _Labeled(
          label: 'normal + icon',
          child: AppChip(
            label: 'Recent',
            icon: AppIcons.retry,
            onTap: () {},
          ),
        ),
        _Labeled(
          label: 'selected',
          child: AppChip(
            label: 'Horror',
            state: ChipState.selected,
            onTap: () {},
          ),
        ),
        _Labeled(
          label: 'selected + icon',
          child: AppChip(
            label: 'Filters',
            state: ChipState.selected,
            icon: AppIcons.filter,
            onTap: () {},
          ),
        ),
        _Labeled(
          label: 'suggestion',
          child: AppChip(
            label: 'Add genre',
            state: ChipState.suggestion,
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

class _QuizTileSection extends StatefulWidget {
  const _QuizTileSection();

  @override
  State<_QuizTileSection> createState() => _QuizTileSectionState();
}

class _QuizTileSectionState extends State<_QuizTileSection> {
  bool _toggled = false;

  static const double _tileSize = 96;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.lg,
      children: [
        SizedBox(
          width: _tileSize,
          child: _Labeled(
            label: 'tap me (default/selected)',
            child: SizedBox(
              width: _tileSize,
              height: _tileSize,
              child: QuizTile(
                icon: AppIcons.compass,
                label: 'Adventure',
                state: _toggled
                    ? QuizTileState.selected
                    : QuizTileState.normal,
                onTap: () => setState(() => _toggled = !_toggled),
              ),
            ),
          ),
        ),
        SizedBox(
          width: _tileSize,
          child: _Labeled(
            label: 'selected',
            child: SizedBox(
              width: _tileSize,
              height: _tileSize,
              child: QuizTile(
                icon: AppIcons.dice,
                label: 'Comedy',
                state: QuizTileState.selected,
                onTap: () {},
              ),
            ),
          ),
        ),
        SizedBox(
          width: _tileSize,
          child: _Labeled(
            label: 'disabled',
            child: const SizedBox(
              width: _tileSize,
              height: _tileSize,
              child: QuizTile(
                icon: AppIcons.hourglass,
                label: 'Horror',
                state: QuizTileState.disabled,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ButtonsSection extends StatefulWidget {
  const _ButtonsSection();

  @override
  State<_ButtonsSection> createState() => _ButtonsSectionState();
}

class _ButtonsSectionState extends State<_ButtonsSection> {
  bool _isFavorite = false;
  bool _isWatchLater = true;
  bool _isWatched = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PrimaryButton(label: 'Get started', onTap: () {}),
        const SizedBox(height: AppSpacing.sm),
        const PrimaryButton(label: 'Loading…', isLoading: true),
        const SizedBox(height: AppSpacing.sm),
        const PrimaryButton(label: 'Disabled', isDisabled: true),
        const SizedBox(height: AppSpacing.lg),
        SecondaryButton(label: 'My Tastes', onTap: () {}),
        const SizedBox(height: AppSpacing.lg),
        TextLinkButton(label: 'Another suggestion', onTap: () {}),
        const SizedBox(height: AppSpacing.lg),
        DestructiveButton(label: 'Delete My List', onTap: () {}),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          'Icon buttons (tap to toggle)',
          style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            AppIconButton(
              iconOutline: AppIcons.favorite,
              iconFill: AppIcons.favoriteFill,
              isActive: _isFavorite,
              onTap: () => setState(() => _isFavorite = !_isFavorite),
            ),
            const SizedBox(width: AppSpacing.xl),
            AppIconButton(
              iconOutline: AppIcons.watchLater,
              iconFill: AppIcons.watchLaterFill,
              isActive: _isWatchLater,
              onTap: () => setState(() => _isWatchLater = !_isWatchLater),
            ),
            const SizedBox(width: AppSpacing.xl),
            AppIconButton(
              iconOutline: AppIcons.watched,
              iconFill: AppIcons.watchedFill,
              isActive: _isWatched,
              onTap: () => setState(() => _isWatched = !_isWatched),
            ),
          ],
        ),
      ],
    );
  }
}

class _TabBarSection extends StatefulWidget {
  const _TabBarSection();

  @override
  State<_TabBarSection> createState() => _TabBarSectionState();
}

class _TabBarSectionState extends State<_TabBarSection> {
  AppTab _active = AppTab.discover;
  bool _hasActiveRoom = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tap a tab, or the Pako button to toggle the active-room dot',
          style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
        ),
        const SizedBox(height: AppSpacing.md),
        DecoratedBox(
          decoration: const BoxDecoration(color: AppColors.surfaceRaised2),
          child: Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              AppTabBar(
                activeTab: _active,
                onTabSelected: (tab) => setState(() => _active = tab),
              ),
              MatchFab(
                hasActiveRoom: _hasActiveRoom,
                onTap: () => setState(() => _hasActiveRoom = !_hasActiveRoom),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection();

  static const _genreCounts = <(String, int)>[
    ('Comedy', 42),
    ('Drama', 35),
    ('Action', 28),
    ('Horror', 15),
    ('Documentary', 6),
  ];

  @override
  Widget build(BuildContext context) {
    final maxCount = _genreCounts.first.$2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.6,
          children: const [
            MetricCard(value: '128', label: 'Movies watched'),
            MetricCard(value: '312 h', label: 'Hours of movies'),
            MetricCard(value: '34', label: 'TV shows watched'),
            MetricCard(value: '≈ 480 h', label: 'Estimated TV hours'),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          'Genres you watch most',
          style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final (label, count) in _genreCounts)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: GenreBar(label: label, count: count, maxCount: maxCount),
          ),
      ],
    );
  }
}

class _LibraryRowSection extends StatefulWidget {
  const _LibraryRowSection();

  @override
  State<_LibraryRowSection> createState() => _LibraryRowSectionState();
}

class _LibraryRowSectionState extends State<_LibraryRowSection> {
  String _lastSwipe = 'none yet';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LibraryRow(
          posterUrl: null,
          title: 'The Bear',
          metadata: '2022 · TV Show · 2 seasons',
          trailing: LibraryRowTrailing.date('Saved yesterday'),
        ),
        const Divider(color: AppColors.line, height: AppSpacing.xxl),
        const LibraryRow(
          posterUrl: null,
          title: 'Dune: Part Two',
          metadata: '2024 · Movie · 2 h 46 min',
          trailing: LibraryRowTrailing.stars(3),
        ),
        const Divider(color: AppColors.line, height: AppSpacing.xxl),
        const LibraryRow(
          posterUrl: null,
          title: 'Season 1',
          metadata: '2016 · 8 episodes',
          trailing: LibraryRowTrailing.chevron(),
        ),
        const Divider(color: AppColors.line, height: AppSpacing.xxl),
        Text(
          'Swipe left (remove) / right (watched) — last: $_lastSwipe',
          style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
        ),
        const SizedBox(height: AppSpacing.sm),
        LibraryRow(
          posterUrl: null,
          title: 'Knives Out',
          metadata: '2019 · Movie · 2 h 10 min',
          trailing: const LibraryRowTrailing.date('Saved 3 days ago'),
          onSwipeLeft: () => setState(() => _lastSwipe = 'left (remove)'),
          onSwipeRight: () => setState(() => _lastSwipe = 'right (watched)'),
        ),
      ],
    );
  }
}

class _StateViewsSection extends StatelessWidget {
  const _StateViewsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skeleton',
          style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            const SkeletonBlock(width: 110, height: 165),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonBlock(width: 160, height: 16),
                  const SizedBox(height: AppSpacing.sm),
                  const SkeletonBlock(width: 100, height: 12),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          'Empty state',
          style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
        ),
        DecoratedBox(
          decoration: const BoxDecoration(color: AppColors.surfaceRaised),
          child: EmptyStateView(
            title: 'Nothing for later yet',
            body: 'Save a movie or show and it will show up here.',
            ctaLabel: 'Explore',
            onCtaTap: () {},
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          'Error state',
          style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
        ),
        DecoratedBox(
          decoration: const BoxDecoration(color: AppColors.surfaceRaised),
          child: ErrorStateView(
            title: "Couldn't load",
            body: 'Check your connection and try again.',
            onRetry: () {},
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          'Offline banner',
          style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
        ),
        const SizedBox(height: AppSpacing.md),
        const OfflineBanner(),
      ],
    );
  }
}

class _MediaCarouselSection extends StatelessWidget {
  const _MediaCarouselSection();

  static final _movies = [
    Movie(
      id: 1,
      title: 'Dune: Part Two',
      posterUrl: null,
      genres: const [],
      releaseDate: DateTime(2024, 3, 1),
      voteAverage: 8.4,
    ),
    Movie(
      id: 2,
      title: 'Oppenheimer',
      posterUrl: null,
      genres: const [],
      releaseDate: DateTime(2023, 7, 21),
      voteAverage: 8.2,
    ),
    Movie(
      id: 3,
      title: 'Poor Things',
      posterUrl: null,
      genres: const [],
      releaseDate: DateTime(2023, 12, 8),
      voteAverage: 8.0,
    ),
    Movie(
      id: 4,
      title: 'Knives Out',
      posterUrl: null,
      genres: const [],
      releaseDate: DateTime(2019, 11, 27),
      voteAverage: 7.9,
    ),
  ];

  static final _tvShows = [
    TvShow(
      id: 101,
      title: 'The Bear',
      posterUrl: null,
      genres: const [],
      releaseDate: DateTime(2022, 6, 23),
      voteAverage: 8.5,
    ),
    TvShow(
      id: 102,
      title: 'Fallout',
      posterUrl: null,
      genres: const [],
      releaseDate: DateTime(2024, 4, 10),
      voteAverage: 8.3,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'standard (110×165, no snap, showTypeTag: true)',
          style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
        ),
        const SizedBox(height: AppSpacing.md),
        MediaCarousel.standard(
          items: [..._movies, ..._tvShows],
          showTypeTag: true,
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          'hero (330×440, snap, 24px peek — full-bleed, breaks out of the '
          'screen padding)',
          style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: MediaCardSize.hero.height,
          child: OverflowBox(
            minWidth: 0,
            maxWidth: MediaQuery.sizeOf(context).width,
            alignment: Alignment.centerLeft,
            child: MediaCarousel.hero(items: _movies, onSaveTap: (item) {}),
          ),
        ),
      ],
    );
  }
}
