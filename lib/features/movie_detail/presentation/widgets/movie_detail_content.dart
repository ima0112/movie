import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di.dart';
import '../../../../app/router.dart';
import '../../../../core/domain/entities/media_key.dart';
import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'movie_action_row.dart';
import 'movie_cast_row.dart';
import 'movie_detail_header.dart';
import 'movie_similar_section.dart';
import 'movie_synopsis_section.dart';
import 'where_to_watch_section.dart';

/// D1 once `MovieDetailCubit` has loaded — assembles every rule-13 sub-
/// widget inside a `CustomScrollView`/slivers, which is what lets
/// [MovieDetailHeader] scroll underneath the compact bar
/// (`movie_detail_screen.dart` owns the shared `ScrollController` and the
/// bar's visibility). Each sub-widget carries its own `BlocSelector`
/// (rule 9) — this widget itself only lays things out, no Bloc
/// subscription of its own.
///
/// Trailer playback and provider links have no `url_launcher` wired up
/// yet (not discussed/added as a dependency) — a `SnackBar` stands in so
/// the tap is still visibly verifiable.
class MovieDetailContent extends StatelessWidget {
  const MovieDetailContent({
    super.key,
    required this.mediaKey,
    required this.scrollController,
    required this.similarSectionKey,
  });

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

  @override
  Widget build(BuildContext context) {
    final userLibraryRepository = getIt<UserLibraryRepository>();
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: MovieDetailHeader(
            onGenreTap: (genre) =>
                context.push(AppRoutes.genreListing(genre.id, MediaType.movie)),
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
            child: MovieActionRow(
              mediaKey: mediaKey,
              userLibraryRepository: userLibraryRepository,
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
            // TODO(url_launcher): open the provider's link once that
            // dependency is discussed and added.
            onProviderTap: (link) => ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Would open: $link'))),
          ),
        ),
        const SliverToBoxAdapter(child: MovieSynopsisSection()),
        // TODO: onPersonTap/onSeeFullCastTap → D3/H3 once they're built.
        const SliverToBoxAdapter(child: MovieCastRow()),
        SliverToBoxAdapter(
          key: similarSectionKey,
          child: MovieSimilarSection(
            onItemTap: (item) => context.push(AppRoutes.movieDetail(item.id)),
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
