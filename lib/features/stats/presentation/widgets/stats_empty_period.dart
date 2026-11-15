import 'package:flutter/material.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/state_views.dart';

/// C4's state when the chosen period (this year, this month) has nothing
/// watched although other periods do: a quiet note to try another, no CTA.
class StatsEmptyPeriod extends StatelessWidget {
  const StatsEmptyPeriod({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyStateView(
      icon: AppIcons.stats,
      title: context.l10n.statsEmptyPeriodTitle,
      body: context.l10n.statsEmptyPeriodBody,
    );
  }
}
