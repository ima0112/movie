import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/app_tab_bar.dart';
import '../../../../shared/widgets/overline_label.dart';
import '../../../../shared/widgets/scroll_edge_fade.dart';
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
              child: ColoredBox(
                color: AppColors.surface.withValues(alpha: 0.6),
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.screenMargin,
            right: AppSpacing.screenMargin,
            top: 0,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: ExploreRecentsPanel.maxHeightIn(
                  room.maxHeight,
                  barInset: AppTabBar.scrollInset(context),
                ),
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Header(
                        title: l10n.exploreRecentSearchesLabel,
                        onClearAll: cubit.clearRecentSearches,
                      ),
                      const Divider(height: 1, color: AppColors.line),
                      Flexible(
                        child: _FadingList(
                          children: [
                            for (final query in recents)
                              RecentSearchRow(
                                key: ValueKey(query),
                                query: query,
                                onTap: () => cubit.runRecentSearch(query),
                                onRemove: () => cubit.removeRecentSearch(query),
                              ),
                          ],
                        ),
                      ),
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

/// The scrolling rows, fading out at the bottom edge **only while there is
/// more below** (a list that fits is never faded).
class _FadingList extends StatefulWidget {
  const _FadingList({required this.children});

  final List<Widget> children;

  @override
  State<_FadingList> createState() => _FadingListState();
}

class _FadingListState extends State<_FadingList> {
  final _controller = ScrollController();
  bool _moreBelow = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _measure() {
    if (!_controller.hasClients) return;
    final position = _controller.position;
    final more = position.maxScrollExtent - position.pixels > 1;
    if (more != _moreBelow) setState(() => _moreBelow = more);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _measure();
        });
        return false;
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (_) {
          _measure();
          return false;
        },
        child: ScrollEdgeFade(
          top: 0,
          bottom: _moreBelow ? AppSpacing.xxl : 0,
          child: Scrollbar(
            controller: _controller,
            child: ListView(
              controller: _controller,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: widget.children,
            ),
          ),
        ),
      ),
    );
  }
}
