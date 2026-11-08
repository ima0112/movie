import 'package:flutter/widgets.dart';

import '../../../../shared/widgets/state_views.dart';

/// C4's empty state — "empty ('Mark something as watched to see your
/// stats' + CTA)" (`docs/SCREENS.md` C4). Reuses [EmptyStateView] (Pako
/// asleep + title + body + CTA), the same shared widget `MyListEmptyState`
/// already wraps for B4's own empty tabs.
///
/// SCREENS.md gives only that one title line and "+ CTA" with no label
/// or supporting body text — [EmptyStateView] needs both, so the body
/// line and "Explore" CTA label here are this widget's own copy, not a
/// doc quote. "Explore" specifically mirrors `MyListEmptyState`'s CTA
/// for the same underlying situation (nothing watched yet → go find
/// something), rather than inventing a distinct label for it.
class StatsEmptyState extends StatelessWidget {
  const StatsEmptyState({super.key, this.onExploreTap});

  final VoidCallback? onExploreTap;

  @override
  Widget build(BuildContext context) {
    return EmptyStateView(
      title: 'Mark something as watched to see your stats',
      body: 'Your numbers will show up here once you do.',
      ctaLabel: 'Explore',
      onCtaTap: onExploreTap,
    );
  }
}
