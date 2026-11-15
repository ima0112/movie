import 'package:flutter/material.dart';

import '../../../../core/domain/stats/stats_period.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_segmented_control.dart';

/// C4's period control: All time · This year · This month
/// (`docs/SCREENS.md` C4), as the app's [AppSegmentedControl]. Driven by
/// [period] / [onSelected]; the screen's own narrow `BlocSelector` reads the
/// cubit (rule 9).
class StatsPeriodTabs extends StatelessWidget {
  const StatsPeriodTabs({
    super.key,
    required this.period,
    required this.onSelected,
  });

  final StatsPeriod period;
  final ValueChanged<StatsPeriod> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppSegmentedControl<StatsPeriod>(
      padding: EdgeInsets.zero,
      segments: [
        AppSegment(value: StatsPeriod.allTime, label: l10n.statsPeriodAllTime),
        AppSegment(
          value: StatsPeriod.thisYear,
          label: l10n.statsPeriodThisYear,
        ),
        AppSegment(
          value: StatsPeriod.thisMonth,
          label: l10n.statsPeriodThisMonth,
        ),
      ],
      selected: period,
      onSelected: onSelected,
    );
  }
}
