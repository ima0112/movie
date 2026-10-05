import 'package:flutter/material.dart';

import '../../../../core/domain/entities/genre.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/genre_icons.dart';
import '../../../../shared/widgets/quiz_tile.dart';

/// E2 step 1 — `docs/SCREENS.md` E2: "Pick up to 3 you're NOT in the mood
/// for": 4-column grid of genres for the chosen type; icon + name; max
/// 3; counter '1 of 3'."
///
/// "For the chosen type" isn't modeled: [GenreCatalog] (via
/// [genreOptions]) isn't segmented by media type yet — the same gap
/// `explore_content.dart`'s own doc comment already flags for Explore's
/// genre grid (the TMDB-id-per-type mapping that would make this
/// possible lives only in `data/tmdb/`) — so this shows the same 15
/// genres for a movie or a TV session.
///
/// Reuses [QuizTile] directly rather than `TasteGenreGrid` (C5's own
/// wrapper): that widget always renders its own title text, which
/// doesn't fit this step's "headline + counter" layout.
class QuizGenreStep extends StatelessWidget {
  const QuizGenreStep({
    super.key,
    required this.selected,
    required this.onToggle,
  });

  final Set<Genre> selected;
  final ValueChanged<Genre> onToggle;

  static const int _max = 3;
  static const int _crossAxisCount = 4;

  @override
  Widget build(BuildContext context) {
    final atMax = selected.length >= _max;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Pick up to 3 you're NOT in the mood for", style: AppTextStyles.h1),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '${selected.length} of $_max',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
        ),
        const SizedBox(height: AppSpacing.lg),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _crossAxisCount,
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: 1,
          ),
          itemCount: genreOptions.length,
          itemBuilder: (context, index) {
            final (genre, icon) = genreOptions[index];
            final isSelected = selected.contains(genre);

            return QuizTile(
              icon: icon,
              label: genre.name,
              // A genre already at the cap and not itself selected shows
              // disabled (30% opacity, inert) — QuizTileState's own doc
              // comment already covers this exact "picked elsewhere,
              // now shown while picking the opposite set" case, and E2's
              // own "max 3" reads the same way.
              state: isSelected
                  ? QuizTileState.selected
                  : (atMax ? QuizTileState.disabled : QuizTileState.normal),
              onTap: () => onToggle(genre),
            );
          },
        ),
      ],
    );
  }
}
