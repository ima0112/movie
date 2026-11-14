import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// One row of B2's search results — the same list tile as D3b's filmography
/// (`docs/SCREENS.md` D3b): a [leading] slot (a poster, or a person's round
/// photo), the [title] and a muted [subtitle], an optional [third] line, a
/// chevron that says tapping goes to more info, and a hairline underneath.
/// The page margin comes from the list around it, so the hairlines run the
/// width of the content.
///
/// Pure presentation: everything comes in by parameter.
class SearchResultTile extends StatelessWidget {
  const SearchResultTile({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.third,
    this.trailing,
    this.onLongPress,
  });

  /// The 52×76 slot at the start: a poster, or a round photo centered in it.
  final Widget leading;
  final String title;
  final String subtitle;

  /// A line under the subtitle (a title's ★ rating); `null` for none.
  final Widget? third;
  final VoidCallback onTap;

  /// Replaces the chevron at the end (a three-dot button); `null` keeps it.
  final Widget? trailing;
  final VoidCallback? onLongPress;

  static const double leadingWidth = 52;
  static const double leadingHeight = 76;
  static const double _chevron = 20;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.line)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: leadingWidth,
              height: leadingHeight,
              child: leading,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.h3,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.inkMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (third != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    third!,
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            trailing ??
                const Icon(
                  AppIcons.chevronRight,
                  size: _chevron,
                  color: AppColors.inkMuted,
                ),
          ],
        ),
      ),
    );
  }
}
