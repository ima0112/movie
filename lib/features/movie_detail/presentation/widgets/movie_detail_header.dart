import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/genre.dart';
import '../../../../core/domain/entities/media_detail.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/scrim_back_button.dart';
import '../cubit/movie_detail_cubit.dart';
import 'movie_detail_title_block.dart';

/// D1's header: full-bleed poster, fade to black, back button, and the
/// centered title/metadata/rating/genres block ([MovieDetailTitleBlock]).
///
/// Source of truth: `docs/SCREENS.md` D1 ("Header (55% of the height):
/// full-bleed poster... fade to black starting at 60%..."). Carries its
/// own `BlocSelector` on the loaded [MovieDetail] (rule 9) — renders
/// nothing while loading/erroring, which is the assembled screen's job to
/// cover with a skeleton/error view. The compact scroll-linked app bar
/// SCREENS.md also calls for needs a shared `ScrollController`, so it's
/// the assembling screen's job too.
class MovieDetailHeader extends StatelessWidget {
  const MovieDetailHeader({super.key, this.onGenreTap});

  /// Tapping a genre → C1 with that genre and type Movies (SCREENS.md
  /// D1). `null` until the assembled screen wires real navigation.
  final void Function(Genre genre)? onGenreTap;

  // docs/SCREENS.md D1: "Header (55% of the height)". Public: the
  // assembled screen needs the same value to know when the title has
  // "scrolled past the top" and the compact bar should appear.
  static const double heightFraction = 0.55;
  static const List<double> _fadeStops = [0.6, 1];

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MovieDetailCubit, MovieDetailState, MovieDetail?>(
      selector: (state) => switch (state) {
        MovieDetailLoaded(detail: MovieDetail movie) => movie,
        _ => null,
      },
      builder: (context, detail) {
        if (detail == null) return const SizedBox.shrink();
        return SizedBox(
          height: MediaQuery.sizeOf(context).height * heightFraction,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _Poster(posterUrl: detail.item.posterUrl),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: _fadeStops,
                    colors: [Colors.transparent, Color(0xFF000000)],
                  ),
                ),
              ),
              const ScrimBackButton(),
              Positioned(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                bottom: AppSpacing.xl,
                child: MovieDetailTitleBlock(
                  detail: detail,
                  onGenreTap: onGenreTap,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Poster extends StatelessWidget {
  const _Poster({required this.posterUrl});

  final String? posterUrl;

  @override
  Widget build(BuildContext context) {
    final url = posterUrl;
    if (url == null) return const ColoredBox(color: AppColors.surfaceRaised2);
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const ColoredBox(color: AppColors.surfaceRaised2),
    );
  }
}
