import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../l10n/l10n_extension.dart';

/// The three-dot button at the end of a list row (My List's rows and people),
/// a 48 px tap target that opens the row's actions sheet.
class RowMoreButton extends StatelessWidget {
  const RowMoreButton({super.key, required this.onTap});

  final VoidCallback onTap;

  static const double _iconSize = 22;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      excludeSemantics: true,
      label: context.l10n.myListRowActionsLabel,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: const SizedBox(
          width: kMinInteractiveDimension,
          height: kMinInteractiveDimension,
          child: Icon(AppIcons.more, size: _iconSize, color: AppColors.ink),
        ),
      ),
    );
  }
}
