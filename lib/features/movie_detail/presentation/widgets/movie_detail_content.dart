import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di.dart';
import '../../../../app/router.dart';
import '../../../../core/domain/entities/country.dart';
import '../../../../core/domain/entities/discover_filter.dart';
import '../../../../core/domain/entities/media_detail.dart';
import '../../../../core/domain/entities/media_key.dart';
import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/domain/repositories/settings_repository.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../core/launch/launch_external_link.dart';
import '../../../../core/launch/media_share.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/genre_localization.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/locale_names.dart';
import '../../../../shared/widgets/media_detail/full_cast_sheet.dart';
import '../../../../shared/widgets/media_detail/media_cast_row.dart';
import '../../../../shared/widgets/media_detail/media_detail_action_row.dart';
import '../../../../shared/widgets/media_detail/media_detail_header.dart';
import '../../../../shared/widgets/media_detail/media_similar_section.dart';
import '../../../../shared/widgets/media_detail/media_stat_cards.dart';
import '../../../../shared/widgets/media_detail/media_synopsis_section.dart';
import '../../../../shared/widgets/media_detail/where_to_watch_section.dart';
import '../../../../shared/widgets/region_sheet.dart';
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

  void _openRegionSheet(BuildContext context) {
    final settingsRepository = getIt<SettingsRepository>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => RegionSheet(
        selectedRegionCode: settingsRepository.current.regionCode,
        onSelected: (code) => unawaited(
          settingsRepository.save(
            settingsRepository.current.copyWith(regionCode: code),
          ),
        ),
      ),
    );
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

  /// D1's Duration / Classification stat cards — each only when TMDB has it.
  List<MediaStat> _stats(BuildContext context) {
    final l10n = context.l10n;
    final runtime = detail.runtimeMinutes;
    final certification = detail.certification;
    return [
      if (runtime != null)
        MediaStat(
          label: l10n.mediaDetailDuration,
          value: movieRuntimeLabel(runtime, l10n),
        ),
      if (certification != null && certification.isNotEmpty)
        MediaStat(label: l10n.mediaDetailClassification, value: certification),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final userLibraryRepository = getIt<UserLibraryRepository>();
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: MediaDetailHeader(
            imageUrl: detail.backdropUrl ?? detail.item.posterUrl,
            title: detail.item.title,
            tagline: detail.tagline,
            onShare: () => unawaited(
              shareMedia(context, title: detail.item.title, key: mediaKey),
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
              metaPrefix: movieMetaPrefix(context, detail),
              extraChips: [
                if (detail.originalLanguage?.trim().isNotEmpty ?? false)
                  languageDisplayName(context, detail.originalLanguage!),
              ],
              onGenreTap: (genre) => context.push(
                AppRoutes.filteredList,
                extra: FilteredListRouteArgs(
                  filter: DiscoverFilter(
                    type: MediaType.movie,
                    withGenres: {genre},
                  ),
                  title: genre.localizedName(context.l10n),
                ),
              ),
              onPlayTrailer: (trailer) =>
                  unawaited(launchYoutubeTrailer(context, trailer.key)),
              onSeeSimilar: _scrollToSimilar,
            ),
          ),
        ),
        SliverToBoxAdapter(child: MediaStatCards(stats: _stats(context))),
        SliverToBoxAdapter(
          child: MediaSynopsisSection(overview: detail.overview),
        ),
        SliverToBoxAdapter(
          child: WhereToWatchSection(
            providers: detail.watchProviders,
            regionName: countryName(
              getIt<SettingsRepository>().current.regionCode,
            ),
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
            onSeeFullCastTap: () => _openFullCastSheet(context),
            showCrew: false,
          ),
        ),
        SliverToBoxAdapter(
          key: similarSectionKey,
          child: MediaSimilarSection(
            title: context.l10n.mediaSimilarMoviesTitle,
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
          context.l10n.onboardingWelcomeTmdbAttribution,
          style: AppTextStyles.caption.copyWith(color: AppColors.inkDim),
        ),
      ),
    );
  }
}
