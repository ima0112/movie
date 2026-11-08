import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/vibe_tile_grid.dart';
import '../../../match_engine/domain/vibe.dart';

/// C5's "Vibes you like" — the "4-column grid of the 16 vibes"
/// (`docs/SCREENS.md` C5), rendered by the shared [VibeTileGrid] (also
/// used by E2's `quiz_vibe_step.dart`). This wrapper only adds C5's own
/// fixed "Vibes you like" caption above it — E2 needs a different
/// headline, which is why that caption lives here and not in the shared
/// grid itself.
class TasteVibeGrid extends StatelessWidget {
  const TasteVibeGrid({
    super.key,
    required this.vibes,
    required this.selected,
    required this.onToggle,
  });

  final List<Vibe> vibes;

  /// Selected vibe ids — matches `TasteProfile.likedVibes`'s own shape.
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Vibes you like', style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.md),
        VibeTileGrid(vibes: vibes, selected: selected, onToggle: onToggle),
      ],
    );
  }
}
