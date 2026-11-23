import 'package:flutter/material.dart';

import '../../../../core/domain/stats/surprise_summary.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/number_format_extension.dart';
import '../../../../shared/widgets/overline_label.dart';
import '../../../../core/theme/app_spacing.dart';
import 'you_metric_row.dart';

/// Surprise me's mini summary inside B5's stats card: a "SURPRISE ME" label and
/// two numbers — the sessions run and the titles chosen — in the same look as
/// the library's strip.
class YouSurpriseSummary extends StatelessWidget {
  const YouSurpriseSummary({super.key, required this.summary});

  final SurpriseSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OverlineLabel(l10n.youStatsSurpriseTitle),
        const SizedBox(height: AppSpacing.md),
        YouMetricRow(
          metrics: [
            (
              summary.sessions.localizedCount(l10n),
              l10n.youStatsSurpriseSessions,
            ),
            (summary.picks.localizedCount(l10n), l10n.youStatsSurprisePicks),
          ],
        ),
      ],
    );
  }
}
