import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/l10n_extension.dart';
import '../expandable_text.dart';
import '../overline_label.dart';

/// D1/D2's synopsis: an italic tagline (if present) + the overview
/// folded to 4 lines (see `ExpandableText` for the Read more / Read less
/// toggle).
///
/// Source of truth: `docs/SCREENS.md` D1, reused unchanged by D2. Pure
/// presentation — [overview]/[tagline] arrive as plain values (CLAUDE.md
/// rule 9 — the assembling screen already knows it's loaded).
class MediaSynopsisSection extends StatelessWidget {
  const MediaSynopsisSection({super.key, required this.overview, this.tagline});

  final String overview;
  final String? tagline;

  static const int _foldedMaxLines = 4;

  @override
  Widget build(BuildContext context) {
    if (overview.isEmpty) return const SizedBox.shrink();

    final tagline = this.tagline;
    return Padding(
      padding: AppSpacing.sectionPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OverlineLabel(context.l10n.mediaDetailSynopsis),
          const SizedBox(height: AppSpacing.itemGap),
          if (tagline != null && tagline.isNotEmpty) ...[
            Text(
              tagline,
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.inkMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          ExpandableText(overview, maxLines: _foldedMaxLines),
        ],
      ),
    );
  }
}
