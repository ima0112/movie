import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// One toggle of [MediaDetailActionRow] — D1/D2 both use it unchanged
/// (`docs/SCREENS.md`). A 44 px circle with a 20 px icon: outlined (`lineStrong`
/// border, `ink` icon) when off, filled amber with a near-black icon when on.
/// It has no visible label; [label] is its accessibility label.
class MediaActionButton extends StatelessWidget {
  const MediaActionButton({
    super.key,
    required this.iconOutline,
    required this.iconFill,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData iconOutline;
  final IconData iconFill;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  static const double size = 44;
  static const double _iconSize = 20;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: isActive,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.accent : null,
            border: Border.all(
              color: isActive ? AppColors.accent : AppColors.lineStrong,
            ),
          ),
          child: Icon(
            isActive ? iconFill : iconOutline,
            size: _iconSize,
            color: isActive ? AppColors.onAccent : AppColors.ink,
          ),
        ),
      ),
    );
  }
}
