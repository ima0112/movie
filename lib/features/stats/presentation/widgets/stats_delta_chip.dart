import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';

/// A small "+4 vs last month" pill: an arrow up / down / flat and the
/// difference, with what it is compared to. Amber when it grew, muted
/// otherwise (a drop is not an error here).
///
/// Pure presentation — everything comes in by parameter.
class StatsDeltaChip extends StatelessWidget {
  const StatsDeltaChip({
    super.key,
    required this.delta,
    required this.previousLabel,
  });

  final int delta;

  /// What [delta] is against, e.g. "vs last month".
  final String previousLabel;

  static const double _icon = 14;

  @override
  Widget build(BuildContext context) {
    final color = delta > 0 ? AppColors.accent : AppColors.inkMuted;
    final icon = delta > 0
        ? AppIcons.trendUp
        : delta < 0
        ? AppIcons.trendDown
        : AppIcons.trendFlat;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: _icon, color: color),
        const SizedBox(width: AppSpacing.xs),
        Text(
          context.l10n.statsDelta(
            delta > 0 ? '+$delta' : '$delta',
            previousLabel,
          ),
          style: AppTextStyles.caption.copyWith(color: color),
        ),
      ],
    );
  }
}
