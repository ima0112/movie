import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/l10n_extension.dart';
import 'where_to_watch_region_button.dart';

/// The top of the Where-to-watch card: the title on one line, always whole,
/// and the region pill — as wide as its text, no wider — at the right on the
/// same row. The title has priority: the pill gets what is left beside it (its
/// name ends in an ellipsis if even that is short), and when what is left is
/// less than [minPillWidth] the pill goes under the title instead, at the left,
/// so the title is never cut or wrapped.
class WhereToWatchHeader extends StatelessWidget {
  const WhereToWatchHeader({
    super.key,
    required this.regionName,
    required this.onRegionTap,
  });

  final String regionName;
  final VoidCallback? onRegionTap;

  /// The least width worth giving the pill beside the title: its two icons,
  /// padding and a few letters of the name.
  static const double minPillWidth = 112;

  @override
  Widget build(BuildContext context) {
    final title = context.l10n.whereToWatchTitle;
    final pill = WhereToWatchRegionButton(name: regionName, onTap: onRegionTap);
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: title, style: AppTextStyles.h2),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          maxLines: 1,
        )..layout();
        final titleWidth = painter.width;
        painter.dispose();
        final beside =
            constraints.maxWidth - titleWidth - AppSpacing.md >= minPillWidth;
        final titleText = Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.h2,
        );
        if (beside) {
          return Row(
            children: [
              titleText,
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Align(alignment: Alignment.centerRight, child: pill),
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleText,
            const SizedBox(height: AppSpacing.md),
            pill,
          ],
        );
      },
    );
  }
}
