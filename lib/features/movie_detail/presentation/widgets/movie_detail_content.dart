import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di.dart';
import '../../../../app/router.dart';
import '../../../../core/domain/entities/discover_filter.dart';
import '../../../../core/domain/entities/media_detail.dart';
import '../../../../core/domain/entities/media_key.dart';
import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/media_detail/full_cast_sheet.dart';
import '../../../../shared/widgets/media_detail/media_cast_row.dart';
import '../../../../shared/widgets/media_detail/media_detail_action_row.dart';
import '../../../../shared/widgets/media_detail/media_detail_header.dart';
import '../../../../shared/widgets/media_detail/media_similar_section.dart';
import '../../../../shared/widgets/media_detail/media_synopsis_section.dart';
import '../../../../shared/widgets/media_detail/where_to_watch_section.dart';
import 'movie_metadata.dart';

/// D1 once `MovieDetailCubit` has loaded — assembles the shared,
/// generic `media_detail` widgets (`shared/widgets/media_detail/`) inside
/// a `CustomScrollView`/slivers, which is what lets
/// `MediaDetailHeader` scroll underneath the compact bar
/// (`movie_detail_screen.dart` owns the shared `ScrollController` and the
/// bar's visibility).
///
/// [detail] arrives already loaded and already narrowed to [MovieDetail]
/// — the *only* place in D1 that reads `MovieDetailCubit`'s state at all
/// is `movie_detail_screen.dart`'s own top-level `BlocBuilder`; every
/// widget below this one is a plain, Cubit-unaware function of the
/// values passed in (CLAUDE.md rule 9 — there is nothing left to
/// rebuild independently once the detail is loaded, since none of it
/// changes again while this is mounted — the one exception,
/// `MediaDetailActionRow`'s own favorite/watch-later state, keeps its
/// own narrow `StreamBuilder` on `UserLibraryRepository` exactly as
/// before).
///
/// Trailer playback and provider links have no `url_launcher` wired up
/// yet (not discussed/added as a dependency) — a `SnackBar` stands in so
/// the tap is still visibly verifiable.
class MovieDetailContent extends StatelessWidget {
  const MovieDetailContent({
    super.key,
    required this.detail,
    required this.mediaKey,
    required this.scrollController,
    required this.similarSectionKey,
  });

  final MovieDetail detail;
  final MediaKey mediaKey;
  final ScrollController scrollController;
  final GlobalKey similarSectionKey;

  void _scrollToSimilar() {
    final similarContext = similarSectionKey.currentContext;
    if (similarContext != null) {
      Scrollable.ensureVisible(
        similarContext,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  void _openFullCastSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => FullCastSheet(
        cast: detail.cast,
        crew: detail.crew,
        onPersonTap: (person) => context.pushPersonDetail(person.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userLibraryRepository = getIt<UserLibraryRepository>();
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: MediaDetailHeader(
            posterUrl: detail.item.posterUrl,
            title: detail.item.title,
            metadataLine: movieMetadataLine(detail),
            voteAverage: detail.item.voteAverage,
            genres: detail.item.genres,
            onGenreTap: (genre) => context.push(
              AppRoutes.filteredList,
              extra: FilteredListRouteArgs(
                filter: DiscoverFilter(
                  type: MediaType.movie,
                  withGenres: {genre},
                ),
                title: genre.name,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.xl,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: MediaDetailActionRow(
              mediaKey: mediaKey,
              userLibraryRepository: userLibraryRepository,
              mediaDetail: detail,
              // TODO(url_launcher): open the YouTube app/browser once
              // that dependency is discussed and added.
              onPlayTrailer: (trailer) =>
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Would open trailer: ${trailer.key}'),
                    ),
                  ),
              onSeeSimilar: _scrollToSimilar,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: WhereToWatchSection(
            providers: detail.watchProviders,
            // Same hardcoded 'ES'/Spain assumption as
            // TmdbMediaRepository._region and MediaDetail._userLanguage
            // — no real settings source exists yet.
            regionName: 'Spain',
            // TODO(H6): wire this once Settings (B5) actually has a
            // region picker to open — docs/SCREENS.md H6 ("Region |
            // B5 | Searchable list of countries") isn't built yet
            // (no Settings feature/screen exists at all).
            onRegionTap: null,
            // TODO(url_launcher): open the provider's link once that
            // dependency is discussed and added.
            onProviderTap: (link) => ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Would open: $link'))),
          ),
        ),
        SliverToBoxAdapter(
          child: MediaSynopsisSection(
            overview: detail.overview,
            tagline: detail.tagline,
          ),
        ),
        SliverToBoxAdapter(
          child: MediaCastRow(
            cast: detail.cast,
            crew: detail.crew,
            onPersonTap: (person) => context.pushPersonDetail(person.id),
            onSeeFullCastTap: () => _openFullCastSheet(context),
          ),
        ),
        SliverToBoxAdapter(
          key: similarSectionKey,
          child: MediaSimilarSection(
            similar: detail.similar,
            onItemTap: (item) => context.pushMediaDetail(item.key),
          ),
        ),
        const SliverToBoxAdapter(child: _Footer()),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Center(
        child: Text(
          'Data from TMDB',
          style: AppTextStyles.caption.copyWith(color: AppColors.inkDim),
        ),
      ),
    );
  }
}
