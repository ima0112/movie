import 'package:flutter/material.dart';

import '../../../../core/domain/stats/library_insights.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';

/// C4's closing note, always shown: "Based on 12 of 14 titles with full
/// data." — how many watched titles carry the genres, year and duration the
/// figures above need (`docs/SCREENS.md` C4). Pure presentation.
class StatsCoverageNote extends StatelessWidget {
  const StatsCoverageNote({super.key, required this.insights});

  final LibraryInsights insights;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sectionGap),
      child: Text(
        context.l10n.statsCoverage(
          insights.completeCount,
          insights.watchedCount,
        ),
        textAlign: TextAlign.center,
        style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
      ),
    );
  }
}
