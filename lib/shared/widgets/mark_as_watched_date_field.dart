import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/l10n_extension.dart';

/// [MarkAsWatchedSheet]'s tappable date row — the formatted date plus a
/// chevron affordance; opens `showDatePicker` (via [onTap]) when tapped.
/// Split out into its own file purely to keep that file under CLAUDE.md
/// rule 11's 150-line soft limit — same reasoning as
/// `rating_stars_selector.dart`'s split.
///
/// Formats through `intl`'s own [DateFormat.yMMMd], not a hand-rolled
/// English month list — already locale-correct for every locale
/// `GlobalMaterialLocalizations.delegate` (wired in `app.dart`)
/// initializes date symbols for, same fix as `library_row.dart`'s own
/// relative-date formatter.
class MarkAsWatchedDateField extends StatelessWidget {
  const MarkAsWatchedDateField({
    super.key,
    required this.date,
    required this.onTap,
  });

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DateFormat.yMMMd(context.l10n.localeName).format(date),
            style: AppTextStyles.body,
          ),
          const Icon(AppIcons.chevronDown, size: 20, color: AppColors.inkMuted),
        ],
      ),
    );
  }
}
