import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// A quiz tile's visual state.
///
/// Source of truth: `docs/DESIGN_SYSTEM.md` section 5.3 ("Tile de
/// cuestionario/género — default / seleccionado / deshabilitado (30%
/// opacidad)").
enum QuizTileState {
  /// `surfaceRaised` background, `ink` icon/label.
  normal,

  /// `accent` background, `onAccent` icon/label.
  selected,

  /// Same as [normal] but at 30% opacity and inert — doesn't respond to
  /// taps (e.g. a genre already picked as "liked", now shown while
  /// picking "never" genres — see `docs/SCREENS.md` A2 step 3).
  disabled,
}

/// Square tile for a genre or vibe grid (onboarding, quiz). Fills
/// whatever box it's given — pair it with a `GridView`'s
/// `childAspectRatio: 1` to keep it square.
///
/// Pure presentation — no feature dependency, everything comes in by
/// parameter.
class QuizTile extends StatefulWidget {
  const QuizTile({
    super.key,
    required this.icon,
    required this.label,
    this.state = QuizTileState.normal,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final QuizTileState state;
  final VoidCallback? onTap;

  @override
  State<QuizTile> createState() => _QuizTileState();
}

class _QuizTileState extends State<QuizTile> {
  // Bumped on every tap to replay the selection-pulse animation below.
  int _pulse = 0;

  // docs/SCREENS.md A2 step 2/3: "24 px outline icon + 13 px label".
  static const double _iconSize = 24;
  static const double _disabledOpacity = 0.3;

  void _handleTap() {
    setState(() => _pulse++);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.state == QuizTileState.disabled;
    final isSelected = widget.state == QuizTileState.selected;
    final foreground = isSelected ? AppColors.onAccent : AppColors.ink;

    final tile = DecoratedBox(
      decoration: BoxDecoration(
        color: isSelected ? AppColors.accent : AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: _iconSize, color: foreground),
              const SizedBox(height: AppSpacing.xs),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySm.copyWith(color: foreground),
              ),
            ],
          ),
        ),
      ),
    );

    return Opacity(
      opacity: isDisabled ? _disabledOpacity : 1,
      child: GestureDetector(
        onTap: isDisabled ? null : _handleTap,
        // docs/DESIGN_SYSTEM.md section 7: "Selección de tile/chip: escala
        // 0.96 → 1, 120 ms" — replayed on every tap via the `_pulse` key.
        child: TweenAnimationBuilder<double>(
          key: ValueKey(_pulse),
          tween: Tween(begin: 0.96, end: 1),
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          builder: (context, scale, child) {
            return Transform.scale(scale: scale, child: child);
          },
          child: tile,
        ),
      ),
    );
  }
}
