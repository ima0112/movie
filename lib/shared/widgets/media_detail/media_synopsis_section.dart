import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// D1/D2's synopsis: an italic tagline (if present) + the overview
/// folded to 4 lines with an amber "Read more".
///
/// Source of truth: `docs/SCREENS.md` D1, reused unchanged by D2. Pure
/// presentation — [overview]/[tagline] arrive as plain values (CLAUDE.md
/// rule 9 — the assembling screen already knows it's loaded); the
/// "read more" expand is local widget state, not Cubit state — it has
/// no meaning outside this one widget's lifecycle (rule 10 applies to
/// shared data, not this).
class MediaSynopsisSection extends StatefulWidget {
  const MediaSynopsisSection({super.key, required this.overview, this.tagline});

  final String overview;
  final String? tagline;

  @override
  State<MediaSynopsisSection> createState() => _MediaSynopsisSectionState();
}

class _MediaSynopsisSectionState extends State<MediaSynopsisSection> {
  static const int _foldedMaxLines = 4;

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.overview.isEmpty) return const SizedBox.shrink();

    final tagline = widget.tagline;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Text(
            widget.overview,
            style: AppTextStyles.body,
            maxLines: _expanded ? null : _foldedMaxLines,
            overflow: _expanded ? null : TextOverflow.ellipsis,
          ),
          // Always offered when folded — measuring real overflow needs
          // a LayoutBuilder/TextPainter pass this widget doesn't do
          // yet; tapping it when the text already fit is harmless.
          if (!_expanded) ...[
            const SizedBox(height: AppSpacing.xs),
            GestureDetector(
              onTap: () => setState(() => _expanded = true),
              child: Text(
                'Read more',
                style: AppTextStyles.bodySm.copyWith(color: AppColors.accent),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
