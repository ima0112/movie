import 'package:flutter/material.dart';

import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../core/domain/stats/library_stats.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/library_tab_localization.dart';
import '../../../../l10n/number_format_extension.dart';
import 'you_metric_row.dart';

/// The four big numbers of You's stats card — watched · hours · favorites ·
/// watch later — in a strip with hairline dividers
/// (`docs/SCREENS.md` B5).
class YouMetricStrip extends StatelessWidget {
  const YouMetricStrip({super.key, required this.stats});

  final LibraryStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final metrics = [
      (
        stats.watchedCount.localizedCount(l10n),
        LibraryTab.watched.localizedLabel(l10n),
      ),
      (
        stats.totalHours.round().localizedCount(l10n),
        l10n.yourActivityHoursLabel,
      ),
      (
        stats.favoritesCount.localizedCount(l10n),
        LibraryTab.favorites.localizedLabel(l10n),
      ),
      (
        stats.watchLaterCount.localizedCount(l10n),
        LibraryTab.watchLater.localizedLabel(l10n),
      ),
    ];
    return YouMetricRow(metrics: metrics);
  }
}
