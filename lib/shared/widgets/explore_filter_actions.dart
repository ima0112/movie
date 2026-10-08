import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../l10n/l10n_extension.dart';
import 'app_buttons.dart';

/// H8's bottom row — "'Reset' and 'See N results' (N live) buttons"
/// (`docs/SCREENS.md` H8). "Reset" only shows when there's something to
/// reset (H8's own wording), matching H9's identical rule for its own
/// "Reset". Split out of `explore_filter_sheet.dart` per CLAUDE.md rule
/// 11.
class ExploreFilterActions extends StatelessWidget {
  const ExploreFilterActions({
    super.key,
    required this.showReset,
    required this.onReset,
    required this.liveCount,
    required this.onApply,
  });

  final bool showReset;
  final VoidCallback onReset;

  /// `null` while the live count is still loading.
  final int? liveCount;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        if (showReset) ...[
          Expanded(
            child: SecondaryButton(label: l10n.commonReset, onTap: onReset),
          ),
          const SizedBox(width: AppSpacing.md),
        ],
        Expanded(
          child: PrimaryButton(
            label: liveCount == null
                ? l10n.filterSheetSeeResultsLoading
                : l10n.filterSheetSeeResultsCount(liveCount!),
            onTap: onApply,
          ),
        ),
      ],
    );
  }
}
