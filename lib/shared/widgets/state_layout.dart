import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_tab_bar.dart';

/// The one layout of every full-area state (empty, error, offline) —
/// `docs/SCREENS.md` G: an icon in a 72 px `surfaceRaised` circle, a headline,
/// a body and any [actions] under them, all centered.
///
/// It centers in the room the floating [AppTabBar] leaves free, not in the
/// whole body (which runs under the bar), so a state looks the same on a root
/// tab as on a pushed screen — `AppTabBar.scrollInset` is just the safe area
/// where there is no bar. And it never overflows: a `LayoutBuilder` +
/// scrollable keeps the normal case centered with nothing to scroll, and only
/// scrolls once the content genuinely doesn't fit (a large text scale, the
/// keyboard open; CLAUDE.md rule 14).
class StateLayout extends StatelessWidget {
  const StateLayout({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.actions = const [],
  });

  final IconData icon;
  final String title;
  final String body;

  /// Buttons or links under the body, top to bottom, centered.
  final List<Widget> actions;

  static const double _badgeSize = 72;
  static const double _iconSize = 32;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTabBar.scrollInset(context)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.hasBoundedHeight
                    ? (constraints.maxHeight - AppSpacing.xl * 2).clamp(
                        0.0,
                        double.infinity,
                      )
                    : 0,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ExcludeSemantics(
                      child: Container(
                        width: _badgeSize,
                        height: _badgeSize,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surfaceRaised,
                        ),
                        child: Icon(
                          icon,
                          size: _iconSize,
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      title,
                      style: AppTextStyles.h2,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      body,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.inkMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    for (final (i, action) in actions.indexed) ...[
                      SizedBox(height: i == 0 ? AppSpacing.xxl : AppSpacing.md),
                      action,
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
