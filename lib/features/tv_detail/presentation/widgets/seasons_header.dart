import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// D2b's top block: the show's name big, and under it one muted line —
/// "● Ended · 5 seasons · 62 episodes" — whose dot is the status colour
/// ([statusColor]: green airing, grey ended, red cancelled). No card, no chips.
/// All of [parts] arrive already localized.
class SeasonsHeader extends StatelessWidget {
  const SeasonsHeader({
    super.key,
    required this.title,
    required this.statusColor,
    required this.parts,
  });

  final String title;
  final Color statusColor;

  /// The status, the season count and the episode count, in that order (the
  /// last two only when known).
  final List<String> parts;

  static const double _dot = 8;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.display,
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Centred on the first line of text.
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm - 1),
              child: Container(
                width: _dot,
                height: _dot,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                parts.join(' · '),
                style: AppTextStyles.body.copyWith(color: AppColors.inkMuted),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
