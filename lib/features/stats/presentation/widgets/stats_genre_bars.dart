import 'package:flutter/material.dart';

import '../../../../core/domain/entities/genre.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/genre_localization.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/genre_bar.dart';

/// C4's "'Genres you watch most': list of 5 horizontal bars with name
/// and count" (`docs/SCREENS.md` C4). Reuses [GenreBar] as-is for each
/// row; this widget is the section title and the list itself.
///
/// Takes [topGenres] pre-ranked (see `LibraryStatsCalculator.topGenres`)
/// rather than raw counts — ranking/tie-breaking is domain logic, not a
/// widget's job. Renders nothing if empty (no watched entry has genre
/// data yet) rather than an empty section with just a title.
///
/// Pure presentation — no Cubit here; the screen that assembles C4 reads
/// `StatsCubit`'s state and passes `stats.topGenres` in.
class StatsGenreBars extends StatelessWidget {
  const StatsGenreBars({super.key, required this.topGenres});

  final List<(Genre, int)> topGenres;

  @override
  Widget build(BuildContext context) {
    if (topGenres.isEmpty) return const SizedBox.shrink();

    // Already ranked most-watched first, so the first entry's count is
    // the bar scale every other bar is drawn relative to.
    final maxCount = topGenres.first.$2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Genres you watch most', style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.md),
        for (final (genre, count) in topGenres)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: GenreBar(
              label: genre.localizedName(context.l10n),
              count: count,
              maxCount: maxCount,
            ),
          ),
      ],
    );
  }
}
