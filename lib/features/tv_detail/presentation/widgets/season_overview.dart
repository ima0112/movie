import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';

/// H4's season synopsis: muted, folded to 2 lines with an amber
/// "Read more".
class SeasonOverview extends StatefulWidget {
  const SeasonOverview({super.key, required this.overview});

  final String overview;

  @override
  State<SeasonOverview> createState() => _SeasonOverviewState();
}

class _SeasonOverviewState extends State<SeasonOverview> {
  static const int _foldedMaxLines = 2;

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.overview,
          style: AppTextStyles.body.copyWith(color: AppColors.inkMuted),
          maxLines: _expanded ? null : _foldedMaxLines,
          overflow: _expanded ? null : TextOverflow.ellipsis,
        ),
        if (!_expanded) ...[
          const SizedBox(height: AppSpacing.xs),
          GestureDetector(
            onTap: () => setState(() => _expanded = true),
            child: Text(
              context.l10n.commonReadMore,
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
