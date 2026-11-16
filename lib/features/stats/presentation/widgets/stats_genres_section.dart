import 'package:flutter/material.dart';

import '../../../../core/domain/entities/genre.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_section.dart';
import 'stats_genre_row.dart';

/// C4's "Genres you watch most": a card listing the genres with an icon, a
/// bar and the share of all the genres counted — the top [collapsedCount],
/// with a "Show all (N)" / "Show less" link when there are more. Absent when
/// no watched title has genre data (`docs/SCREENS.md` C4).
///
/// Pure presentation; the expanded flag is the only state it owns.
class StatsGenresSection extends StatefulWidget {
  const StatsGenresSection({
    super.key,
    required this.genres,
    required this.genreTotal,
  });

  /// Every genre, most watched first.
  final List<(Genre, int)> genres;
  final int genreTotal;

  static const int collapsedCount = 6;

  @override
  State<StatsGenresSection> createState() => _StatsGenresSectionState();
}

class _StatsGenresSectionState extends State<StatsGenresSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final genres = widget.genres;
    if (genres.isEmpty) return const SizedBox.shrink();
    final l10n = context.l10n;
    final shown = _expanded
        ? genres
        : genres.take(StatsGenresSection.collapsedCount).toList();
    final top = genres.first.$2;
    final canExpand = genres.length > StatsGenresSection.collapsedCount;
    return AppSection(
      title: l10n.statsGenreBarsTitle,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.cardPadding,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            children: [
              for (final (genre, count) in shown)
                StatsGenreRow(
                  genre: genre,
                  percent: widget.genreTotal == 0
                      ? 0
                      : (count * 100 / widget.genreTotal).round(),
                  fraction: top == 0 ? 0 : count / top,
                ),
              if (canExpand)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => setState(() => _expanded = !_expanded),
                    child: Text(
                      _expanded
                          ? l10n.statsGenresShowLess
                          : l10n.statsGenresShowAll(genres.length),
                      style: AppTextStyles.action.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
