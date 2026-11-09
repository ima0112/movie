import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n_extension.dart';

/// The four bottom-bar destinations. The Match button that sits between
/// [explore] and [myList] is a separate widget — see `match_fab.dart`.
///
/// Source of truth: `docs/SCREENS.md` section B ("Discover · Explore ·
/// [Pako button] · My List · You. Four tabs (icon only, as in the "Barra
/// inferior flotante" design; active in white with an amber dot, inactive in gray)... Visible on the 4 roots; hidden in
/// details, quiz, rooms, and inside the Match modal.").
enum AppTab {
  discover(icon: AppIcons.home, iconFill: AppIcons.homeFill),
  explore(icon: AppIcons.compass, iconFill: AppIcons.compassFill),
  myList(icon: AppIcons.list, iconFill: AppIcons.listFill),
  you(icon: AppIcons.user, iconFill: AppIcons.userFill);

  const AppTab({required this.icon, required this.iconFill});

  final IconData icon;
  final IconData iconFill;
}

/// CLAUDE.md rule 15: [AppTab] itself carries no label text — only this
/// extension does, switching on the enum value.
extension AppTabLocalization on AppTab {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    AppTab.discover => l10n.navTabDiscover,
    AppTab.explore => l10n.navTabExplore,
    AppTab.myList => l10n.navTabMyList,
    AppTab.you => l10n.navTabYou,
  };
}

/// The floating glass tab bar: a rounded, blurred pill inset from the
/// screen edges, with 4 icon tabs and a center gap for [MatchFab], which
/// the parent shell stacks on top, half-raised above the pill.
///
/// Pure presentation — no feature dependency, everything comes in by
/// parameter. Labels are kept as accessibility semantics only.
class AppTabBar extends StatelessWidget {
  const AppTabBar({super.key, required this.activeTab, this.onTabSelected});

  final AppTab activeTab;
  final ValueChanged<AppTab>? onTabSelected;

  /// Total height of the bar's own box, including the room [MatchFab]
  /// takes above the pill.
  static const double height = 96;

  static const double _pillHeight = 68;
  static const double _pillTop = 12;
  static const double _pillRadius = 34;
  static const double _blur = 24;

  // Room for the FAB in the middle of the pill.
  static const double _centerGap = 64;

  @override
  Widget build(BuildContext context) {
    final leftTabs = AppTab.values.take(2);
    final rightTabs = AppTab.values.skip(2);

    return SafeArea(
      top: false,
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            _pillTop,
            AppSpacing.lg,
            height - _pillTop - _pillHeight,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_pillRadius),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 30,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_pillRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: _blur, sigmaY: _blur),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.glass,
                    borderRadius: BorderRadius.circular(_pillRadius),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        for (final tab in leftTabs) _expanded(tab),
                        const SizedBox(width: _centerGap),
                        for (final tab in rightTabs) _expanded(tab),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _expanded(AppTab tab) => Expanded(
    child: _TabItem(tab: tab, isActive: tab == activeTab, onTap: onTabSelected),
  );
}

class _TabItem extends StatelessWidget {
  const _TabItem({required this.tab, required this.isActive, this.onTap});

  final AppTab tab;
  final bool isActive;
  final ValueChanged<AppTab>? onTap;

  static const double _iconSize = 26;
  static const double _dotSize = 5;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.ink : AppColors.inkMuted;

    return Semantics(
      button: true,
      selected: isActive,
      label: tab.localizedLabel(context.l10n),
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap == null ? null : () => onTap!(tab),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? tab.iconFill : tab.icon,
              size: _iconSize,
              color: color,
            ),
            const SizedBox(height: AppSpacing.xs),
            Container(
              width: _dotSize,
              height: _dotSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? AppColors.accent : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
