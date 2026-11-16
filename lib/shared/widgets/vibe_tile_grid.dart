import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../features/match_engine/domain/vibe.dart';
import '../../l10n/l10n_extension.dart';
import '../../l10n/vibe_localization.dart';
import 'vibe_icon.dart';

/// A 4-column grid of [Vibe] tiles — E2 step 2 ("4-column grid of the 16
/// vibes... exactly 3"). Icon-only tiles, unlike `QuizTile`: 16 tiles at 4/row
/// leaves no room for a permanent caption, so each name shows as a [Tooltip]
/// instead — it already reveals on long-press on a touch device by default.
/// (C5 shows its vibes as chips with their icons instead.)
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
        child: Icon(
          vibeIconFor(widget.vibe),
          size: _iconSize,
          color: foreground,
        ),
      ),
    );

    return Tooltip(
      message: widget.vibe.localizedName(context.l10n),
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
