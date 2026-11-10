import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/expandable_text.dart';

/// H4's season synopsis: muted, folded to 2 lines (see `ExpandableText`).
class SeasonOverview extends StatelessWidget {
  const SeasonOverview({super.key, required this.overview});

  final String overview;

  @override
  Widget build(BuildContext context) {
    return ExpandableText(
      overview,
      maxLines: 2,
      style: AppTextStyles.body.copyWith(color: AppColors.inkMuted),
    );
  }
}
