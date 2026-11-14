import 'package:flutter/material.dart';

import '../../core/theme/app_icons.dart';
import '../../l10n/l10n_extension.dart';
import 'scrim_icon_button.dart';

/// D1/D2's Share button: a [ScrimIconButton] with the share icon. Its
/// accessibility label is "Share"; [onTap] does the sharing.
class ScrimShareButton extends StatelessWidget {
  const ScrimShareButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ScrimIconButton(
      icon: AppIcons.share,
      label: context.l10n.mediaDetailShare,
      onTap: onTap,
    );
  }
}
