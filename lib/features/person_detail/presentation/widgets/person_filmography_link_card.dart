import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_section.dart';

/// D3's "Filmography" block: the heading and one card, "View full
/// filmography · 64 titles ›", that opens D3b ("Persona" design). Nothing is
/// drawn for a person with no credits.
class PersonFilmographyLinkCard extends StatelessWidget {
  const PersonFilmographyLinkCard({
    super.key,
    required this.titleCount,
    required this.onTap,
  });

  final int titleCount;
  final VoidCallback onTap;

  static const double _minHeight = 56;

  @override
  Widget build(BuildContext context) {
    if (titleCount == 0) return const SizedBox.shrink();

    final l10n = context.l10n;
    final count = l10n.personFilmographyTitleCount(titleCount);
    return AppSection(
      title: l10n.personFilmographyTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            button: true,
            excludeSemantics: true,
            label: '${l10n.personFilmographyLinkLabel}, $count',
            child: GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                constraints: const BoxConstraints(minHeight: _minHeight),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.personFilmographyLinkLabel,
                        style: AppTextStyles.h3,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      count,
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.inkMuted,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs + 2),
                    const Icon(
                      AppIcons.chevronRight,
                      size: 18,
                      color: AppColors.inkMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
