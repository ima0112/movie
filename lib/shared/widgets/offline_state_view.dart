import 'package:flutter/material.dart';

import '../../core/theme/app_icons.dart';
import '../../l10n/l10n_extension.dart';
import 'app_buttons.dart';
import 'state_layout.dart';

/// The offline state (`docs/SCREENS.md` G): a wifi-off icon, "You're offline",
/// the amber "Retry" and — only where the screen can offer it ([onGoToMyList],
/// the root tabs Home and Explore) — a "Go to My List" link, because the list
/// is local and still works.
///
/// Pure presentation — everything comes in by parameter.
class OfflineStateView extends StatelessWidget {
  const OfflineStateView({super.key, this.onRetry, this.onGoToMyList});

  final VoidCallback? onRetry;
  final VoidCallback? onGoToMyList;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final goToMyList = onGoToMyList;
    return StateLayout(
      icon: AppIcons.wifiOff,
      title: l10n.offlineStateTitle,
      body: l10n.offlineStateBody,
      actions: [
        AccentButton(label: l10n.commonRetry, onTap: onRetry, fullWidth: false),
        if (goToMyList != null)
          TextLinkButton(
            label: l10n.offlineGoToMyList,
            onTap: goToMyList,
            fullWidth: false,
          ),
      ],
    );
  }
}
