import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/genre.dart';
import '../../../../core/domain/stats/library_stats.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/genre_localization.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/genre_bar.dart';
import '../../../../shared/widgets/overline_label.dart';
import '../cubit/you_stats_cubit.dart';

/// B5's "Your most-watched genres": a card of up to 5 bars, each with the
/// genre's share (a whole percent of every genre counted, so all the genres'
/// shares add up to 100). Draws nothing until a watched title carries genres.
///
/// Selects only the ranking and the total from [YouStatsCubit] (rule 9).
class YouGenresCard extends StatelessWidget {
  const YouGenresCard({super.key});

  static const double _labelWidth = 104;
  static const double _percentWidth = 44;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      YouStatsCubit,
      LibraryStats?,
      (List<(Genre, int)>, int)
    >(
      selector: (stats) =>
          (stats?.topGenres ?? const [], stats?.genreTotal ?? 0),
      builder: (context, ranked) {
        final (genres, total) = ranked;
        if (genres.isEmpty || total == 0) return const SizedBox.shrink();
        final l10n = context.l10n;
        final maxCount = genres.first.$2;
        // Owns the gap above it, so a hidden card leaves no hole.
        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sectionGap),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OverlineLabel(l10n.youGenresTitle),
                  const SizedBox(height: AppSpacing.lg),
                  for (final (genre, count) in genres)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: GenreBar(
                        label: genre.localizedName(l10n),
                        count: count,
                        maxCount: maxCount,
                        labelWidth: _labelWidth,
                        valueWidth: _percentWidth,
                        valueText: l10n.youGenrePercent(
                          (count * 100 / total).round(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
