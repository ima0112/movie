import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/l10n_extension.dart';

/// The mandatory "Data from TMDB" line at the end of a detail screen, with
/// [AppSpacing.sectionGap] above and below.
class TmdbFooter extends StatelessWidget {
  const TmdbFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.sectionPadding.copyWith(
        bottom: AppSpacing.sectionGap,
      ),
      child: Center(
        child: Text(
          context.l10n.onboardingWelcomeTmdbAttribution,
          style: AppTextStyles.caption.copyWith(color: AppColors.inkDim),
        ),
      ),
    );
  }
}
