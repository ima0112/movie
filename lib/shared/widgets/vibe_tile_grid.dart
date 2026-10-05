import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../features/match_engine/domain/vibe.dart';

/// A 4-column grid of [Vibe] tiles — `docs/SCREENS.md` C5 ("4-column
/// grid of the 16 vibes") and E2 step 2 (the identical shape, "4-column
/// grid of the 16 vibes... exactly 3"). Icon-only tiles, unlike
/// `QuizTile`: 16 tiles at 4/row leaves no room for a permanent caption,
/// so each name shows as a [Tooltip] instead — it already reveals on
/// long-press on a touch device by default, exactly what both screens
/// need, no bespoke gesture of ours.
///
/// Promoted from `features/my_tastes/presentation/widgets/
/// taste_vibe_grid.dart` to `shared/widgets/` once `quiz_vibe_step.dart`
/// (E2) became this grid's second real consumer — that file's own
/// hardcoded "Vibes you like" caption stays behind in `TasteVibeGrid`
/// (C5's own wrapper around this), since E2 needs a different headline
/// entirely.
class VibeTileGrid extends StatelessWidget {
  const VibeTileGrid({
    super.key,
    required this.vibes,
    required this.selected,
    required this.onToggle,
  });

  final List<Vibe> vibes;

  /// Selected vibe ids — matches `TasteProfile.likedVibes`'s own shape.
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  static const int _crossAxisCount = 4;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _crossAxisCount,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1,
      ),
      itemCount: vibes.length,
      itemBuilder: (context, index) {
        final vibe = vibes[index];
        return _VibeTile(
          vibe: vibe,
          isSelected: selected.contains(vibe.id),
          onTap: () => onToggle(vibe.id),
        );
      },
    );
  }
}

class _VibeTile extends StatefulWidget {
  const _VibeTile({
    required this.vibe,
    required this.isSelected,
    required this.onTap,
  });

  final Vibe vibe;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_VibeTile> createState() => _VibeTileState();
}

class _VibeTileState extends State<_VibeTile> {
  // Bumped on every tap to replay the selection-pulse animation below —
  // same approach as QuizTile's own.
  int _pulse = 0;

  static const double _iconSize = 24;

  void _handleTap() {
    setState(() => _pulse++);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final foreground = widget.isSelected ? AppColors.onAccent : AppColors.ink;

    final tile = DecoratedBox(
      decoration: BoxDecoration(
        color: widget.isSelected ? AppColors.accent : AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Center(
        child: Icon(_iconFor(widget.vibe), size: _iconSize, color: foreground),
      ),
    );

    return Tooltip(
      message: widget.vibe.name,
      child: GestureDetector(
        onTap: _handleTap,
        // docs/DESIGN_SYSTEM.md section 7: "Selección de tile/chip:
        // escala 0.96 → 1, 120 ms" — replayed on every tap via `_pulse`.
        child: TweenAnimationBuilder<double>(
          key: ValueKey(_pulse),
          tween: Tween(begin: 0.96, end: 1),
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          builder: (context, scale, child) =>
              Transform.scale(scale: scale, child: child),
          child: tile,
        ),
      ),
    );
  }
}

/// Resolves [Vibe.icon] (an `AppIcons` constant *name*, e.g.
/// `"vibeFeelGood"` — a plain `String` since `vibe.dart` stays
/// Flutter-free) to the real icon. Falls back to [AppIcons.dice] if a
/// name doesn't match — shouldn't happen with `assets/vibes.json` as
/// shipped, but a silently wrong icon would be worse than a generic one.
IconData _iconFor(Vibe vibe) => _vibeIcons[vibe.icon] ?? AppIcons.dice;

const Map<String, IconData> _vibeIcons = {
  'vibeFeelGood': AppIcons.vibeFeelGood,
  'vibeIndie': AppIcons.vibeIndie,
  'vibeMonster': AppIcons.vibeMonster,
  'vibeDetective': AppIcons.vibeDetective,
  'vibeClassic': AppIcons.vibeClassic,
  'vibeSuperhero': AppIcons.vibeSuperhero,
  'vibeCult': AppIcons.vibeCult,
  'vibeTearjerker': AppIcons.vibeTearjerker,
  'vibeSports': AppIcons.vibeSports,
  'vibeDate': AppIcons.vibeDate,
  'vibeFuture': AppIcons.vibeFuture,
  'vibeExplosive': AppIcons.vibeExplosive,
  'vibeGritty': AppIcons.vibeGritty,
  'vibeTrueStory': AppIcons.vibeTrueStory,
  'vibeGangster': AppIcons.vibeGangster,
  'vibeMusical': AppIcons.vibeMusical,
};
