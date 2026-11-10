import 'package:flutter/material.dart';

import '../../../../core/domain/entities/genre.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_chip.dart';
import '../../../../shared/widgets/genre_multi_select_chips.dart';

/// One of C5's two genre sections — "Genres you like" or "Genres you
/// avoid" (`docs/SCREENS.md` C5): a title, a one-line hint, and every
/// genre as a wrapping chip. [selectedState] is what a picked genre looks
/// like — amber for "like", red and struck through for "avoid".
///
/// The mutual exclusion between the two sections lives in
/// `MyTastesCubit` (`toggleLikedGenre`/`toggleVetoedGenre` already move a
/// genre out of the opposite set) — this widget only renders whichever
/// [selected] set it's given and calls [onToggle], so the same widget
/// serves both.
class TasteGenreSection extends StatelessWidget {
  const TasteGenreSection({
    super.key,
    required this.title,
    required this.hint,
    required this.genres,
    required this.selected,
    required this.onToggle,
    this.selectedState = ChipState.selected,
  });

  final String title;
  final String hint;
  final List<Genre> genres;
  final Set<Genre> selected;
  final ValueChanged<Genre> onToggle;
  final ChipState selectedState;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.xs),
        Text(
          hint,
          style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
        ),
        const SizedBox(height: AppSpacing.md),
        GenreMultiSelectChips(
          genres: genres,
          selected: selected,
          onToggle: onToggle,
          selectedState: selectedState,
        ),
      ],
    );
  }
}
