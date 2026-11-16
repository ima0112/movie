import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_section.dart';

/// C4's "By decade": a card with one column per release decade (oldest
/// first), tall in proportion to how many watched titles it holds; the
/// busiest decade is amber, the rest a muted amber, each with its count above
/// and its label below. Absent with no dated title (`docs/SCREENS.md` C4).
///
/// Pure presentation — [decades] is `(decade, count)`, e.g. `(1990, 4)`.
class StatsDecadesSection extends StatelessWidget {
  const StatsDecadesSection({super.key, required this.decades});

  final List<(int, int)> decades;

  static const double _chartHeight = 96;
  static const double _stub = AppSpacing.xs;

  @override
  Widget build(BuildContext context) {
    if (decades.isEmpty) return const SizedBox.shrink();
    final l10n = context.l10n;
    final max = decades.fold<int>(0, (a, d) => d.$2 > a ? d.$2 : a);
    final muted = AppTextStyles.micro.copyWith(color: AppColors.inkMuted);
    return AppSection(
      title: l10n.statsDecadesTitle,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final (decade, count) in decades)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxs,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$count', style: muted),
                        const SizedBox(height: AppSpacing.xs),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: count == max
                                ? AppColors.accent
                                : AppColors.accentLine,
                            borderRadius: BorderRadius.circular(AppSpacing.xxs),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: max == 0
                                ? _stub
                                : _stub + (_chartHeight - _stub) * count / max,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            l10n.statsDecadeLabel(decade),
                            style: muted,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
