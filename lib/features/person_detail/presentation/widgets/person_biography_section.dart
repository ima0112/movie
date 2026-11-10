import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';

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
class PersonBiographySection extends StatefulWidget {
  const PersonBiographySection({
    super.key,
    required this.biography,
    required this.isEnglishFallback,
  });

  final String biography;
  final bool isEnglishFallback;

  @override
  State<PersonBiographySection> createState() => _PersonBiographySectionState();
}

class _PersonBiographySectionState extends State<PersonBiographySection> {
  static const int _foldedMaxLines = 3;

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.biography.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isEnglishFallback) ...[
            Text(
              context.l10n.personBiographyInEnglish,
              style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          Text(
            widget.biography,
            style: AppTextStyles.body,
            maxLines: _expanded ? null : _foldedMaxLines,
            overflow: _expanded ? null : TextOverflow.ellipsis,
          ),
          if (!_expanded) ...[
            const SizedBox(height: AppSpacing.xs),
            GestureDetector(
              onTap: () => setState(() => _expanded = true),
              child: Text(
                context.l10n.commonReadMore,
                style: AppTextStyles.bodySm.copyWith(color: AppColors.accent),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
