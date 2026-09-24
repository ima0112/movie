import 'package:flutter/material.dart';

import '../../../../core/domain/entities/genre.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/quiz_tile.dart';

/// One of C5's two genre grids — "Genres you like" or "Genres you never
/// want" (`docs/SCREENS.md` C5: a "3-column grid" each, "mutually
/// exclusive with the above"). Reuses [QuizTile], the same tile A2's
/// onboarding steps 2/3 already use for this exact shape.
///
/// The mutual exclusion itself lives in `MyTastesCubit`
/// (`toggleLikedGenre`/`toggleVetoedGenre` already move a genre out of
/// the opposite set the moment it's toggled into this one — see that
/// Cubit's own doc comment) — this widget only renders whichever
/// [selected] set it's given and calls [onToggle] on a tap; it has no
/// idea "liked" and "vetoed" are related at all, so the same widget
/// serves both sections.
///
/// Takes `(Genre, IconData)` pairs, not a bare `List<Genre>`: there's no
/// genre catalog anywhere in `core/domain` yet (the same gap
/// `MyTastesCubit`'s own doc comment flags) and `Genre` itself carries
/// no icon, so resolving "every selectable genre, with its icon" is
/// left entirely to whoever assembles C5's screen — this widget only
/// renders whatever pairs it's handed.
class TasteGenreGrid extends StatelessWidget {
  const TasteGenreGrid({
    super.key,
    required this.title,
    required this.options,
    required this.selected,
    required this.onToggle,
  });

  final String title;
  final List<(Genre, IconData)> options;
  final Set<Genre> selected;
  final ValueChanged<Genre> onToggle;

  static const int _crossAxisCount = 3;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.md),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _crossAxisCount,
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: 1,
          ),
          itemCount: options.length,
          itemBuilder: (context, index) {
            final (genre, icon) = options[index];
            return QuizTile(
              icon: icon,
              label: genre.name,
              state: selected.contains(genre)
                  ? QuizTileState.selected
                  : QuizTileState.normal,
              onTap: () => onToggle(genre),
            );
          },
        ),
      ],
    );
  }
}
