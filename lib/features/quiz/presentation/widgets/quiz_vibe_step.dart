import 'package:flutter/material.dart';

import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/vibe_tile_grid.dart';
import '../../../match_engine/domain/vibe_catalog.dart';

/// E2 step 2 — `docs/SCREENS.md` E2: "Now pick 3 you ARE in the mood
/// for": 4-column grid of the 16 vibes; exactly 3; counter '3 of 3'."
///
/// Renders [VibeTileGrid] (the shared grid + long-press tooltip, also
/// used by C5's `TasteVibeGrid`) rather than that wrapper directly: C5's
/// own hardcoded "Vibes you like" caption doesn't fit this step's
/// headline, so only the grid itself is reused.
///
/// Takes [vibeCatalog] + [mediaType] rather than an already-filtered
/// `List<Vibe>`: resolving "the 16 vibes" for whichever type this
/// session is about (`Vibe.isMeaningfulFor`) is this step's own job, the
/// same way `VibeCatalog.availableFor` is documented to work.
class QuizVibeStep extends StatelessWidget {
  const QuizVibeStep({
    super.key,
    required this.vibeCatalog,
    required this.mediaType,
    required this.selected,
    required this.onToggle,
  });

  final VibeCatalog vibeCatalog;
  final MediaType mediaType;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  static const int _required = 3;

  @override
  Widget build(BuildContext context) {
    final vibes = vibeCatalog.availableFor(mediaType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Now pick 3 you ARE in the mood for', style: AppTextStyles.h1),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '${selected.length} of $_required',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
        ),
        const SizedBox(height: AppSpacing.lg),
        VibeTileGrid(vibes: vibes, selected: selected, onToggle: onToggle),
      ],
    );
  }
}
