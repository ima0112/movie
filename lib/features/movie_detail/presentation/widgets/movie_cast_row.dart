import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/media_detail.dart';
import '../../../../core/domain/entities/person.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/movie_detail_cubit.dart';
import 'movie_cast_circle.dart';
import 'movie_crew_line.dart';

/// D1's cast circles + the director/writer line.
///
/// Source of truth: `docs/SCREENS.md` D1 ("Cast: 10 circles at 64 px with
/// name and character... Director and writer: tappable names separated by
/// '·'"). Both → D3 (Person detail, not built yet) — [onPersonTap] lets
/// the assembled screen wire that once it exists.
///
/// Carries its own `BlocSelector` on just cast/crew (rule 9).
class MovieCastRow extends StatelessWidget {
  const MovieCastRow({super.key, this.onPersonTap, this.onSeeFullCastTap});

  final void Function(Person person)? onPersonTap;

  /// "See full cast" → H3 (not built yet).
  final VoidCallback? onSeeFullCastTap;

  static const double _circleSize = 64;
  static const int _visibleCount = 10;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MovieDetailCubit, MovieDetailState, MovieDetail?>(
      selector: (state) => switch (state) {
        MovieDetailLoaded(detail: MovieDetail movie) => movie,
        _ => null,
      },
      builder: (context, detail) {
        if (detail == null || detail.cast.isEmpty) {
          return const SizedBox.shrink();
        }
        final visibleCast = detail.cast.take(_visibleCount).toList();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: _circleSize + AppSpacing.xxl,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: visibleCast.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final member = visibleCast[index];
                    return MovieCastCircle(
                      member: member,
                      size: _circleSize,
                      onTap: () => onPersonTap?.call(member.person),
                    );
                  },
                ),
              ),
              if (detail.cast.length > _visibleCount) ...[
                const SizedBox(height: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: GestureDetector(
                    onTap: onSeeFullCastTap,
                    child: Text(
                      'See full cast',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ),
              ],
              if (detail.crew.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: MovieCrewLine(
                    crew: detail.crew,
                    onPersonTap: onPersonTap,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
