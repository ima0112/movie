import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'match_fab.dart';

/// The four bottom-bar destinations. The Match button that sits between
/// [explore] and [myList] is a separate widget — see `match_fab.dart`.
///
/// Source of truth: `docs/SCREENS.md` section B ("Discover · Explore ·
/// [Pako button] · My List · You. Four tabs (24 px icon + 11 px label;
/// active in white, inactive in gray)... Visible on the 4 roots; hidden in
/// details, quiz, rooms, and inside the Match modal.").
enum AppTab {
  discover(
    icon: AppIcons.home,
    iconFill: AppIcons.homeFill,
    label: 'Discover',
  ),
  explore(
    icon: AppIcons.compass,
    iconFill: AppIcons.compassFill,
    label: 'Explore',
  ),
  myList(icon: AppIcons.list, iconFill: AppIcons.listFill, label: 'My List'),
  you(icon: AppIcons.user, iconFill: AppIcons.userFill, label: 'You');

  const AppTab({
    required this.icon,
    required this.iconFill,
    required this.label,
  });

  final IconData icon;
  final IconData iconFill;
  final String label;
}

/// The 4-tab bottom bar. Leaves a center gap the width of [MatchFab] so a
/// parent shell can stack the Match button on top, straddling this bar
/// and the screen above it.
///
/// Pure presentation — no feature dependency, everything comes in by
/// parameter.
class AppTabBar extends StatelessWidget {
  const AppTabBar({super.key, required this.activeTab, this.onTabSelected});

  final AppTab activeTab;
  final ValueChanged<AppTab>? onTabSelected;

  // Room for the FAB to sit in, split evenly on each side.
  static const double _centerGap = MatchFab.diameter + AppSpacing.md;

  @override
  Widget build(BuildContext context) {
    final leftTabs = AppTab.values.take(2);
    final rightTabs = AppTab.values.skip(2);

    return ColoredBox(
      color: AppColors.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            children: [
              for (final tab in leftTabs)
                Expanded(
                  child: _TabItem(
                    tab: tab,
                    isActive: tab == activeTab,
                    onTap: onTabSelected,
                  ),
                ),
              const SizedBox(width: _centerGap),
              for (final tab in rightTabs)
                Expanded(
                  child: _TabItem(
                    tab: tab,
                    isActive: tab == activeTab,
                    onTap: onTabSelected,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({required this.tab, required this.isActive, this.onTap});

  final AppTab tab;
  final bool isActive;
  final ValueChanged<AppTab>? onTap;

  static const double _iconSize = 24;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.ink : AppColors.inkMuted;

    return GestureDetector(
      onTap: onTap == null ? null : () => onTap!(tab),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? tab.iconFill : tab.icon,
            size: _iconSize,
            color: color,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(tab.label, style: AppTextStyles.caption.copyWith(color: color)),
        ],
      ),
    );
  }
}
