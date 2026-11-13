import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';

/// One row of the recent searches panel: a clock, the query, and a × that
/// removes it. Tapping the row runs the search.
class RecentSearchRow extends StatelessWidget {
  const RecentSearchRow({
    super.key,
    required this.query,
    required this.onTap,
    required this.onRemove,
  });

  final String query;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  static const double height = 56;
  static const double _icon = 22;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xl),
          child: Row(
            children: [
              const Icon(
                AppIcons.history,
                size: _icon,
                color: AppColors.inkMuted,
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Text(
                  query,
                  style: AppTextStyles.body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                tooltip: context.l10n.exploreRecentRemove(query),
                onPressed: onRemove,
                icon: const Icon(
                  AppIcons.close,
                  size: _icon,
                  color: AppColors.inkMuted,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
          ),
        ),
      ),
    );
  }
}
