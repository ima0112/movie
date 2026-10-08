import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/app_chip.dart';

/// B2's "Recent" chips — "last 10; tap to run, long-press to remove;
/// 'Clear all'" (`docs/SCREENS.md` B2). Only shown in State 1 (at rest);
/// renders nothing once there's no history at all rather than an empty
/// "Recent" header with nothing under it.
///
/// Pure presentation — no feature dependency, everything comes in by
/// parameter.
class RecentSearchesChips extends StatelessWidget {
  const RecentSearchesChips({
    super.key,
    required this.recentSearches,
    required this.onTap,
    required this.onLongPress,
    required this.onClearAll,
  });

  final List<String> recentSearches;

  /// A chip tap — "tap to run".
  final ValueChanged<String> onTap;

  /// A chip long-press — "long-press to remove".
  final ValueChanged<String> onLongPress;

  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    if (recentSearches.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.exploreRecentSearchesLabel,
              style: AppTextStyles.h3,
            ),
            TextLinkButton(
              label: context.l10n.commonClearAll,
              onTap: onClearAll,
              fullWidth: false,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final query in recentSearches)
              GestureDetector(
                onLongPress: () => onLongPress(query),
                child: AppChip(label: query, onTap: () => onTap(query)),
              ),
          ],
        ),
      ],
    );
  }
}
