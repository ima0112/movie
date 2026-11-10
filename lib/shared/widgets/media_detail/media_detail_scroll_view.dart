import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/domain/entities/country.dart';
import '../../../core/domain/entities/discover_filter.dart';
import '../../../core/domain/entities/media_detail.dart';
import '../../../core/domain/entities/media_key.dart';
import '../../../core/domain/repositories/user_library_repository.dart';
import '../../../core/launch/launch_external_link.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/genre_localization.dart';
import '../../../l10n/l10n_extension.dart';
import '../region_sheet.dart';
import '../tmdb_footer.dart';
import 'media_cast_row.dart';
import 'media_detail_action_row.dart';
import 'media_detail_header.dart';
import 'media_similar_section.dart';
import 'media_stat_cards.dart';
import 'media_synopsis_section.dart';
import 'where_to_watch_section.dart';

/// The whole loaded body of D1/D2, one assembly for both: backdrop header →
/// trailer + info card → [stats] cards → synopsis → where to watch → cast →
/// [castByline] → similar → TMDB footer (`docs/SCREENS.md` D1/D2).
///
/// Movie and TV differ only in what they pass in — [metaPrefix],
/// [extraChips], [stats], [castByline], [similarTitle] — so the order, the
/// spacing and every navigation (genre → C1, "See all" cast → D1b, a person
/// → D3, a title → D1/D2, region → H6) live here once.
///
/// Pure of any Cubit (CLAUDE.md rule 9): the screen's own top-level
/// `BlocBuilder` is the only reader of the loaded state; the region choice
/// goes back out through [onRegionSelected].
class MediaDetailScrollView extends StatefulWidget {
  const MediaDetailScrollView({
    super.key,
    required this.detail,
    required this.mediaKey,
    required this.scrollController,
    required this.similarSectionKey,
    required this.userLibraryRepository,
    required this.regionCode,
    required this.onRegionSelected,
    required this.metaPrefix,
    this.extraChips = const [],
    this.stats = const [],
    this.castByline,
    this.similarTitle,
  });

  final MediaDetail detail;
  final MediaKey mediaKey;
  final ScrollController scrollController;
  final GlobalKey similarSectionKey;
  final UserLibraryRepository userLibraryRepository;

  /// The region "Where to watch" shows right now (the screen's own pick, else
  /// the saved one).
  final String regionCode;

  /// The user picked a country in H6 — reload this screen for it only.
  final ValueChanged<String> onRegionSelected;

  /// The info card's text before the genres, and its chips after the rating.
  final String metaPrefix;
  final List<String> extraChips;

  /// The cards under the info card (D1: Duration/Classification; D2:
  /// Status/Seasons).
  final List<MediaStat> stats;

  /// The credit line under the Cast heading (D1: "Directed by ...", D2:
  /// "Created by ..."), a `MediaByline`.
  final Widget? castByline;

  /// Overrides the default "Similar" heading ("Similar movies").
  final String? similarTitle;

  @override
  State<MediaDetailScrollView> createState() => _MediaDetailScrollViewState();
}

class _MediaDetailScrollViewState extends State<MediaDetailScrollView> {
  final GlobalKey _whereToWatchKey = GlobalKey();

  MediaDetail get detail => widget.detail;

  void _scrollTo(GlobalKey key) {
    final target = key.currentContext;
    if (target != null) {
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  void _openFullCast(BuildContext context) => unawaited(
    context.push(
      AppRoutes.fullCast,
      extra: FullCastRouteArgs(
        title: detail.item.title,
        cast: detail.cast,
        crew: detail.crew,
      ),
    ),
  );

  void _openRegionSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => RegionSheet(
        selectedRegionCode: widget.regionCode,
        onSelected: widget.onRegionSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: widget.scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: MediaDetailHeader(
            imageUrl: detail.backdropUrl ?? detail.item.posterUrl,
            title: detail.item.title,
            tagline: detail.tagline,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenMargin,
            AppSpacing.screenMargin,
            AppSpacing.screenMargin,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: MediaDetailActionRow(
              mediaKey: widget.mediaKey,
              userLibraryRepository: widget.userLibraryRepository,
              mediaDetail: detail,
              metaPrefix: widget.metaPrefix,
              extraChips: widget.extraChips,
              onGenreTap: (genre) => context.push(
                AppRoutes.filteredList,
                extra: FilteredListRouteArgs(
                  filter: DiscoverFilter(
                    type: detail.item.type,
                    withGenres: {genre},
                  ),
                  title: genre.localizedName(context.l10n),
                ),
              ),
              onPlayTrailer: (trailer) =>
                  unawaited(launchYoutubeTrailer(context, trailer.key)),
              onSeeSimilar: detail.similar.isEmpty
                  ? null
                  : () => _scrollTo(widget.similarSectionKey),
              onSeeWhereToWatch: detail.watchProviders.hasAny
                  ? () => _scrollTo(_whereToWatchKey)
                  : null,
            ),
          ),
        ),
        SliverToBoxAdapter(child: MediaStatCards(stats: widget.stats)),
        SliverToBoxAdapter(
          child: MediaSynopsisSection(overview: detail.overview),
        ),
        SliverToBoxAdapter(
          key: _whereToWatchKey,
          child: WhereToWatchSection(
            providers: detail.watchProviders,
            regionName: countryName(widget.regionCode),
            onRegionTap: () => _openRegionSheet(context),
            onProviderTap: (link) =>
                unawaited(launchExternalLink(context, link)),
          ),
        ),
        SliverToBoxAdapter(
          child: MediaCastRow(
            cast: detail.cast,
            crew: detail.crew,
            onPersonTap: (person) => context.pushPersonDetail(person.id),
            onSeeFullCastTap: () => _openFullCast(context),
            byline: widget.castByline,
          ),
        ),
        SliverToBoxAdapter(
          key: widget.similarSectionKey,
          child: MediaSimilarSection(
            title: widget.similarTitle,
            similar: detail.similar,
            onItemTap: (item) => context.pushMediaDetail(item.key),
          ),
        ),
        const SliverToBoxAdapter(child: TmdbFooter()),
      ],
    );
  }
}
