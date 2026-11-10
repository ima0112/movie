import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di.dart';
import '../../../../core/domain/entities/media_detail.dart';
import '../../../../core/launch/media_share.dart';
import '../../../../core/domain/entities/media_key.dart';
import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/domain/repositories/media_repository.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/failure_localization.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/media_detail/detail_top_controls.dart';
import '../../../../shared/widgets/media_detail/media_detail_header.dart';
import '../../../../shared/widgets/media_detail/media_detail_skeleton.dart';
import '../../../../shared/widgets/scrim_back_button.dart';
import '../../../../shared/widgets/state_views.dart';
import '../cubit/movie_detail_cubit.dart';
import '../widgets/movie_detail_content.dart';

/// D1 (Movie detail).
///
/// Implements `docs/SCREENS.md` D1.
///
/// Thin per CLAUDE.md rule 11: this file only provides `MovieDetailCubit`,
/// owns the shared `ScrollController` the compact bar needs (SCREENS.md
/// D1: "When the title scrolls past the top, a compact black bar
/// appears..."), and picks skeleton/error/content — every actual piece of
/// D1's content, each with its own rule-9 `BlocSelector`, lives in
/// `../widgets/`.
class MovieDetailScreen extends StatelessWidget {
  const MovieDetailScreen({super.key, required this.movieId});

  final int movieId;

  @override
  Widget build(BuildContext context) {
    final mediaKey = MediaKey(type: MediaType.movie, tmdbId: movieId);
    return BlocProvider(
      create: (_) => MovieDetailCubit(
        getIt<MediaRepository>(),
        getIt<UserLibraryRepository>(),
      )..loadDetail(mediaKey),
      child: _MovieDetailView(mediaKey: mediaKey),
    );
  }
}

class _MovieDetailView extends StatefulWidget {
  const _MovieDetailView({required this.mediaKey});

  final MediaKey mediaKey;

  @override
  State<_MovieDetailView> createState() => _MovieDetailViewState();
}

class _MovieDetailViewState extends State<_MovieDetailView> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _similarSectionKey = GlobalKey();
  final ValueNotifier<bool> _showCompactBar = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  // The bar appears once the header (320 px, per
  // MediaDetailHeader.height) has scrolled past a compact bar's
  // worth of space — i.e. the title itself has left the top.
  void _onScroll() {
    final headerHeight = MediaDetailHeader.height;
    _showCompactBar.value =
        _scrollController.offset > headerHeight - kToolbarHeight;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _showCompactBar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // The only `BlocBuilder` on this screen scoped to "is D1
          // loading, errored, or loaded" (CLAUDE.md rule 9) — everything
          // below it selects its own slice of `MovieDetailState`.
          BlocBuilder<MovieDetailCubit, MovieDetailState>(
            builder: (context, state) {
              return switch (state) {
                // Skeleton/error have no MediaDetailHeader of their own
                // (that's normally where ScrimBackButton lives), so each
                // gets its own — otherwise there'd be no way back.
                MovieDetailInitial() || MovieDetailLoading() => const Stack(
                  children: [MediaDetailSkeleton(), ScrimBackButton()],
                ),
                MovieDetailError(:final reason) => Stack(
                  children: [
                    // ErrorStateView sizes itself to its own content
                    // (Padding around a Column with mainAxisSize.min) —
                    // as a bare Stack child it lands top-left, at the
                    // Stack's default alignment, unless something here
                    // centers it explicitly.
                    Center(
                      child: ErrorStateView(
                        title: context.l10n.commonCouldntLoad,
                        body: reason.localizedMessage(context.l10n),
                        onRetry: () => context
                            .read<MovieDetailCubit>()
                            .loadDetail(widget.mediaKey),
                      ),
                    ),
                    const ScrimBackButton(),
                  ],
                ),
                MovieDetailLoaded(:final detail, :final regionCode) =>
                  MovieDetailContent(
                    detail: detail as MovieDetail,
                    mediaKey: widget.mediaKey,
                    scrollController: _scrollController,
                    similarSectionKey: _similarSectionKey,
                    regionCode: regionCode,
                  ),
              };
            },
          ),
          BlocSelector<MovieDetailCubit, MovieDetailState, String?>(
            selector: (state) => switch (state) {
              MovieDetailLoaded(:final detail) => detail.item.title,
              _ => null,
            },
            builder: (context, title) => DetailTopControls(
              showCompact: _showCompactBar,
              title: title,
              onShare: title == null
                  ? null
                  : () => unawaited(
                      shareMedia(context, title: title, key: widget.mediaKey),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
