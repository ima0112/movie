import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import 'match_hub_card.dart';

/// B3 (Match hub) — the sheet the bottom bar's Match button opens.
///
/// Source of truth: `docs/SCREENS.md` B3. A compact sheet — as tall as its
/// content, under the theme's drag handle — with the title "Match" and two
/// cards: "Surprise me" (active) and "Match with friends" (dimmed, with a
/// "Soon" pill, not tappable: the Matcher is v1.1). The "Join a room" block
/// and the "Back to room" card are Matcher-only and not built either.
///
/// Opened via `showModalBottomSheet` (`root_shell.dart`), swipe down to
/// close. Pure presentation — every card's copy and destination is fixed.
class MatchHubSheet extends StatelessWidget {
  const MatchHubSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.matchHubTitle, style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.lg),
            MatchHubCard(
              icon: AppIcons.match,
              title: l10n.matchHubSurpriseMeTitle,
              subtitle: l10n.matchHubSurpriseMeSubtitle,
              highlighted: true,
              onTap: () {
                Navigator.of(context).pop();
                context.push(AppRoutes.surprise);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            MatchHubCard(
              icon: AppIcons.group,
              title: l10n.matchHubWithFriendsTitle,
              subtitle: l10n.matchHubWithFriendsSubtitle,
              pillLabel: l10n.matchHubSoonPill,
            ),
          ],
        ),
      ),
    );
  }
}
