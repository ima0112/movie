import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di.dart';
import '../../../../core/domain/entities/media_detail.dart';
import '../../../../core/domain/entities/media_key.dart';
import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/domain/repositories/media_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/failure_localization.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/media_detail/media_detail_compact_bar.dart';
import '../../../../shared/widgets/media_detail/media_detail_header.dart';
import '../../../../shared/widgets/media_detail/media_detail_skeleton.dart';
import '../../../../shared/widgets/scrim_back_button.dart';
import '../../../../shared/widgets/state_views.dart';
import '../cubit/tv_detail_cubit.dart';
import '../widgets/tv_detail_content.dart';

/// D2 (TV show detail).
///
/// Implements `docs/SCREENS.md` D2.
///
/// Thin per CLAUDE.md rule 11 — identical shape to `MovieDetailScreen`
/// (D1): provides `TvDetailCubit`, owns the shared `ScrollController`
/// the compact bar needs, and picks skeleton/error/content. Kept as its
/// own screen rather than branching inside `MovieDetailScreen`: D1's
/// own content widget is typed to `MovieDetail` specifically
/// (`MovieDetailContent`), so reusing that screen for a `TvShowDetail`
/// would need the same cast-and-hope `MovieDetailContent` itself
/// already avoids by being properly typed.
class TvDetailScreen extends StatelessWidget {
  const TvDetailScreen({super.key, required this.tvId});

  final int tvId;

  @override
  Widget build(BuildContext context) {
    final mediaKey = MediaKey(type: MediaType.tvShow, tmdbId: tvId);
    return BlocProvider(
      create: (_) =>
          TvDetailCubit(getIt<MediaRepository>())..loadDetail(mediaKey),
      child: _TvDetailView(mediaKey: mediaKey),
    );
  }
}

class _TvDetailView extends StatefulWidget {
  const _TvDetailView({required this.mediaKey});

  final MediaKey mediaKey;

  @override
  State<_TvDetailView> createState() => _TvDetailViewState();
}

class _TvDetailViewState extends State<_TvDetailView> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _similarSectionKey = GlobalKey();
  final ValueNotifier<bool> _showCompactBar = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final headerHeight =
        MediaQuery.sizeOf(context).height * MediaDetailHeader.heightFraction;
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
          // The only `BlocBuilder` on this screen (CLAUDE.md rule 9) —
          // everything below it selects its own slice of `TvDetailState`.
          BlocBuilder<TvDetailCubit, TvDetailState>(
            builder: (context, state) {
              return switch (state) {
                TvDetailInitial() || TvDetailLoading() => const Stack(
                  children: [MediaDetailSkeleton(), ScrimBackButton()],
                ),
                TvDetailError(:final reason) => Stack(
                  children: [
                    Center(
                      child: ErrorStateView(
                        title: "Couldn't load",
                        body: reason.localizedMessage(context.l10n),
                        onRetry: () => context.read<TvDetailCubit>().loadDetail(
                          widget.mediaKey,
                        ),
                      ),
                    ),
                    const ScrimBackButton(),
                  ],
                ),
                TvDetailLoaded(:final detail) => TvDetailContent(
                  detail: detail as TvShowDetail,
                  mediaKey: widget.mediaKey,
                  scrollController: _scrollController,
                  similarSectionKey: _similarSectionKey,
                ),
              };
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _showCompactBar,
            builder: (context, visible, child) =>
                visible ? child! : const SizedBox.shrink(),
            child: BlocSelector<TvDetailCubit, TvDetailState, String?>(
              selector: (state) => switch (state) {
                TvDetailLoaded(:final detail) => detail.item.title,
                _ => null,
              },
              builder: (context, title) =>
                  MediaDetailCompactBar(title: title ?? ''),
            ),
          ),
        ],
      ),
    );
  }
}
