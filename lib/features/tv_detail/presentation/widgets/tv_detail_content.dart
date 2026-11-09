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
import '../../../../core/domain/entities/season_summary.dart';
import '../../../../core/domain/repositories/settings_repository.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../core/launch/launch_external_link.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/genre_localization.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/media_detail/full_cast_sheet.dart';
import '../../../../shared/widgets/media_detail/media_cast_row.dart';
import '../../../../shared/widgets/media_detail/media_detail_action_row.dart';
import '../../../../shared/widgets/media_detail/media_detail_header.dart';
import '../../../../shared/widgets/media_detail/media_similar_section.dart';
import '../../../../shared/widgets/media_detail/media_synopsis_section.dart';
import '../../../../shared/widgets/media_detail/where_to_watch_section.dart';
import '../../../../shared/widgets/region_sheet.dart';
import 'season_sheet.dart';
import 'tv_creators_section.dart';
import 'tv_metadata.dart';
import 'tv_seasons_section.dart';
import 'tv_status_pill.dart';

/// D2 once `TvDetailCubit` has loaded — assembles the shared, generic
/// `media_detail` widgets exactly like `MovieDetailContent` (D1), plus
/// D2's own additions: a status pill, "Created by", and "Seasons" →
/// H4 (`docs/SCREENS.md` D2).
///
/// [detail] arrives already loaded and already narrowed to
/// [TvShowDetail] — same "only this content widget reads the loaded
/// state" discipline as D1 (CLAUDE.md rule 9): `TvDetailScreen`'s own
/// top-level `BlocBuilder` is the only place `TvDetailCubit`'s state is
/// read at all.
class TvDetailContent extends StatelessWidget {
  const TvDetailContent({
    super.key,
    required this.detail,
    required this.mediaKey,
    required this.scrollController,
    required this.similarSectionKey,
  });

  final TvShowDetail detail;
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

  void _openSeasonSheet(BuildContext context, SeasonSummary season) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SeasonSheet(
        tvId: mediaKey.tmdbId,
        seasonSummary: season,
        showTitle: detail.item.title,
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
            statusPill: TvStatusPill(status: detail.status),
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
              metaPrefix: [
                tvMetadataLine(detail, context.l10n),
                if (detail.countryCodes.isNotEmpty) detail.countryCodes.first,
              ].where((part) => part.isNotEmpty).join(' · '),
              extraChips: tvInfoChips(detail),
              onGenreTap: (genre) => context.push(
                AppRoutes.filteredList,
                extra: FilteredListRouteArgs(
                  filter: DiscoverFilter(
                    type: MediaType.tvShow,
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
          child: MediaSynopsisSection(overview: detail.overview),
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
          child: TvCreatorsSection(
            creators: detail.creators,
            onPersonTap: (person) => context.pushPersonDetail(person.id),
          ),
        ),
        SliverToBoxAdapter(
          child: TvSeasonsSection(
            seasons: detail.seasons,
            onSeasonTap: (season) => _openSeasonSheet(context, season),
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
          context.l10n.onboardingWelcomeTmdbAttribution,
          style: AppTextStyles.caption.copyWith(color: AppColors.inkDim),
        ),
      ),
    );
  }
}
