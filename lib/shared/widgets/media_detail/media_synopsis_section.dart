import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/l10n_extension.dart';

/// D1/D2's synopsis: an italic tagline (if present) + the overview
/// folded to 4 lines with an amber "Read more" / "Read less" toggle that only shows when the text is really cut.
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

  /// Whether [overview] needs more than [_foldedMaxLines] lines at [width].
  bool _overflows(double width) {
    final painter = TextPainter(
      text: TextSpan(text: widget.overview, style: AppTextStyles.body),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: _foldedMaxLines,
    )..layout(maxWidth: width);
    final result = painter.didExceedMaxLines;
    painter.dispose();
    return result;
  }

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
          Text(
            context.l10n.mediaDetailSynopsis.toUpperCase(),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.inkMuted,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
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
          LayoutBuilder(
            builder: (context, constraints) {
              // The toggle only exists when the folded text really is cut.
              final overflows = _overflows(constraints.maxWidth);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.overview,
                    style: AppTextStyles.body,
                    maxLines: _expanded ? null : _foldedMaxLines,
                    overflow: _expanded ? null : TextOverflow.ellipsis,
                  ),
                  if (overflows) ...[
                    const SizedBox(height: AppSpacing.xs),
                    GestureDetector(
                      onTap: () => setState(() => _expanded = !_expanded),
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        _expanded
                            ? context.l10n.commonReadLess
                            : context.l10n.commonReadMore,
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
