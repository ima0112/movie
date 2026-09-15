import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_text_styles.dart';

/// [MarkAsWatchedSheet]'s tappable date row — the formatted date plus a
/// chevron affordance; opens `showDatePicker` (via [onTap]) when tapped.
/// Split out into its own file purely to keep that file under CLAUDE.md
/// rule 11's 150-line soft limit — same reasoning as
/// `rating_stars_selector.dart`'s split.
class MarkAsWatchedDateField extends StatelessWidget {
  const MarkAsWatchedDateField({
    super.key,
    required this.date,
    required this.onTap,
  });

  final DateTime date;
  final VoidCallback onTap;

  static const _month = 'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(_formatDate(date), style: AppTextStyles.body),
          const Icon(AppIcons.chevronDown, size: 20, color: AppColors.inkMuted),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) =>
      '${_month.split(',')[date.month - 1]} ${date.day}, ${date.year}';
}
