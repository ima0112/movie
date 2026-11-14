import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/app_tab_bar.dart';
import '../../../../shared/widgets/overline_label.dart';
import '../cubit/explore_cubit.dart';
import '../cubit/explore_state.dart';
import 'recent_search_row.dart';

/// B2's recent searches: a panel that drops from under the search field while
/// it is focused, over the segmented control and the page (which dims behind
/// it; tapping the dim dismisses). Its first row — "RECENT" and "Clear all" —
/// is fixed; the searches under it scroll when there are more than fit.
///
/// **A fixed size**: the header and five and a half rows ([visibleRows]),
/// scrolling beyond that, so a good part of the dimmed page is always left to
/// tap to dismiss it. **Adaptive** only where the screen is too short for that:
/// it shrinks to leave the floating tab bar and [minDimBelow] free (the room
/// already excludes the keyboard, the body being resized), so it fits a small
/// phone with the keyboard up. It only exists when the saved history has
/// something in it and the field is empty (typing swaps it for the results).
///
/// Place it as a `Positioned.fill` child of a `Stack` that starts right under
/// the search field. Watches only the recents (CLAUDE.md rule 9).
class ExploreRecentsPanel extends StatelessWidget {
  const ExploreRecentsPanel({super.key, required this.searchFocus});

  /// The search field's focus: the panel shows while it is focused.
  final FocusNode searchFocus;

  /// How many rows show at once: five and a half, so the half-cut sixth row
  /// tells the user there is more to scroll to. The panel has this fixed size
  /// however many searches there are (at most ten are kept).
  static const double visibleRows = 5.5;

  /// The least room left under the panel for the user to tap the dimmed page
  /// to dismiss it.
  static const double minDimBelow = AppSpacing.xxxl * 2;

  /// The panel's tallest size in [room] (the area under the field): a fixed
  /// header plus [visibleRows] rows — and never more than leaves the floating
  /// tab bar ([barInset]: its height, the safe area and a gap) and [minDimBelow]
  /// free, so there is always page to tap under it, even on a small phone with
  /// the keyboard up.
  static double maxHeightIn(double room, {required double barInset}) {
    final fixed = _Header.height + 1 + RecentSearchRow.height * visibleRows;
    return math.max(0, math.min(fixed, room - barInset - minDimBelow));
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ExploreCubit, ExploreState, List<String>>(
      selector: (state) =>
          state is ExploreAtRest ? state.recentSearches : const [],
      builder: (context, recents) {
        return ListenableBuilder(
          listenable: searchFocus,
          builder: (context, _) {
            final visible = searchFocus.hasFocus && recents.isNotEmpty;
            final still = MediaQuery.disableAnimationsOf(context);
            return AnimatedSwitcher(
              duration: still
                  ? Duration.zero
                  : const Duration(milliseconds: 150),
              child: visible
                  ? _Panel(
                      key: const ValueKey('recents'),
                      recents: recents,
                      onDismiss: searchFocus.unfocus,
                    )
                  : const SizedBox.shrink(key: ValueKey('none')),
            );
          },
        );
      },
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({super.key, required this.recents, required this.onDismiss});

  final List<String> recents;
  final VoidCallback onDismiss;

  /// How much the page behind the panel is blurred.
  static const double _blur = 6;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExploreCubit>();
    final l10n = context.l10n;
    // The panel is placed filling the room under the field: that is its height
    // budget.
    return LayoutBuilder(
      builder: (context, room) => Stack(
        children: [
          // The dim behind the panel; a tap on it dismisses.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onDismiss,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: _blur, sigmaY: _blur),
                  child: ColoredBox(
                    color: AppColors.surface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.screenMargin,
            right: AppSpacing.screenMargin,
            top: 0,
            // An explicit height (not a shrink-wrapped list in a constrained
            // box): the list then has a real viewport, so its scrollbar's
            // thumb always matches the scroll position, also after the
            // keyboard resizes the panel.
            child: SizedBox(
              height: math.min(
                ExploreRecentsPanel.maxHeightIn(
                  room.maxHeight,
                  barInset: AppTabBar.scrollInset(context),
                ),
                _Header.height + 1 + RecentSearchRow.height * recents.length,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
                  border: Border.all(color: AppColors.lineStrong),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
                  child: Column(
                    children: [
                      _Header(
                        title: l10n.exploreRecentSearchesLabel,
                        onClearAll: cubit.clearRecentSearches,
                      ),
                      const Divider(height: 1, color: AppColors.line),
                      Expanded(child: _RecentsList(recents: recents)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "RECENT" and "Clear all" — the panel's fixed first row.
class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onClearAll});

  final String title;
  final VoidCallback onClearAll;

  /// Fixed, so the panel's size doesn't depend on the button's own metrics.
  static const double height = 56;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            OverlineLabel(title),
            TextLinkButton(
              label: context.l10n.commonClearAll,
              onTap: onClearAll,
              fullWidth: false,
            ),
          ],
        ),
      ),
    );
  }
}

/// The scrolling rows. A [Scrollbar] insets its track by the ambient
/// `MediaQuery` padding — which on a root tab includes the floating tab bar —
/// so that padding is removed here, or the thumb would stop short of the end.
class _RecentsList extends StatelessWidget {
  const _RecentsList({required this.recents});

  final List<String> recents;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExploreCubit>();
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      child: Scrollbar(
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemExtent: RecentSearchRow.height,
          itemCount: recents.length,
          itemBuilder: (context, index) {
            final query = recents[index];
            return RecentSearchRow(
              key: ValueKey(query),
              query: query,
              onTap: () => cubit.runRecentSearch(query),
              onRemove: () => cubit.removeRecentSearch(query),
            );
          },
        ),
      ),
    );
  }
}
