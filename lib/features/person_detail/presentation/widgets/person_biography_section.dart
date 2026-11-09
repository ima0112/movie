import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/expandable_text.dart';

/// D3's biography — "folded to 3 lines with 'Read more'"
/// (`docs/SCREENS.md` D3; D1/D2's own synopsis folds to 4 — D3's own 5
/// is this screen's own number, not a shared one). Shows a "Biography
/// in English" note above the text when [isEnglishFallback] is set —
/// this task's own addition, for when TMDB has no translation in the
/// user's own language (`PersonDetail.biographyIsEnglishFallback`).
///
/// Same "fold, expand on tap" local-state shape as
/// `MediaSynopsisSection` — not shared with it: that widget is already
/// specific to D1/D2's own `overview`/`tagline` pair, and this one
/// additionally needs the translation note, so copying the ~20 lines
/// involved was simpler than parameterizing a shared one for a single
/// extra optional line.
class PersonBiographySection extends StatelessWidget {
  const PersonBiographySection({
    super.key,
    required this.biography,
    required this.isEnglishFallback,
  });

  final String biography;
  final bool isEnglishFallback;

  static const int _foldedMaxLines = 3;

  @override
  Widget build(BuildContext context) {
    if (biography.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: AppSpacing.sectionPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isEnglishFallback) ...[
            Text(
              context.l10n.personBiographyInEnglish,
              style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          ExpandableText(biography, maxLines: _foldedMaxLines),
        ],
      ),
    );
  }
}
