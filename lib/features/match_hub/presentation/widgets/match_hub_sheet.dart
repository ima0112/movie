import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_halo.dart';
import '../../../../shared/widgets/pako_state.dart';
import 'match_hub_card.dart';

/// B3 (Match hub) — the modal the bottom bar's Pako button opens.
///
/// Source of truth: `docs/SCREENS.md` B3. Two deliberate omissions, both
/// Matcher-only (v1.1, not built — CLAUDE.md's own "don't implement
/// v1.1/v1.2" rule): the "Join a room" code-field block (this branch's
/// own task: "the room-code block doesn't exist yet") and the "Back to
/// room" card for an active session. "Match with friends" itself still
/// appears, per B3's own elements list — just as a "Soon"-pilled,
/// non-tappable [MatchHubCard] rather than one that opens F1.
///
/// Opened via `showModalBottomSheet` (`root_shell.dart`'s own
/// `MatchFab.onTap`), not a route: B3 is explicitly "near-full-screen
/// modal... swipe down to close", the same sheet mechanics
/// `ExploreFilterSheet`/`MyListFilterSheet` already use for H8/H9, not a
/// pushed screen like D1 or C1.
///
/// Pure presentation — no feature dependency, everything comes in by
/// parameter (there are none: every card's destination/copy is fixed by
/// B3 itself).
class MatchHubSheet extends StatelessWidget {
  const MatchHubSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SizedBox(
      // "Near-full-screen modal" — SCREENS.md gives no exact fraction,
      // so this leaves a visible sliver of whatever's behind it (the
      // same affordance a drag handle implies) rather than 100%.
      height: MediaQuery.sizeOf(context).height * 0.9,
      child: Stack(
        children: [
          const Positioned(left: 0, right: 0, top: 0, child: AppHalo()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.8, end: 1),
                      duration: const Duration(milliseconds: 400),
                      // SCREENS.md B3: "Pako gives a small bounce on
                      // open" — a one-shot scale-in on first build.
                      curve: Curves.elasticOut,
                      builder: (context, scale, child) =>
                          Transform.scale(scale: scale, child: child),
                      child: const PakoState(mood: PakoMood.idle),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(l10n.matchHubTitle, style: AppTextStyles.h2),
                  const SizedBox(height: AppSpacing.xl),
                  MatchHubCard(
                    icon: AppIcons.dice,
                    title: l10n.matchHubSurpriseMeTitle,
                    subtitle: l10n.matchHubSurpriseMeSubtitle,
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
          ),
        ],
      ),
    );
  }
}
