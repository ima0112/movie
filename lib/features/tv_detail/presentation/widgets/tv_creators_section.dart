import 'package:flutter/material.dart';

import '../../../../core/domain/entities/person.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';

/// D2's "'Created by': names (→ D3)" (`docs/SCREENS.md` D2) — tappable
/// names separated by "·", the same convention
/// `shared/widgets/media_detail/media_crew_line.dart` uses for D1's
/// "Director and writer" line. Kept as its own small widget rather than
/// reusing that one: [Person] isn't a [CrewMember] (no `.job` to
/// render), and "Created by" isn't a per-role label the way "Director"/
/// "Writer" are.
class TvCreatorsSection extends StatelessWidget {
  const TvCreatorsSection({
    super.key,
    required this.creators,
    this.onPersonTap,
  });

  final List<Person> creators;
  final void Function(Person person)? onPersonTap;

  @override
  Widget build(BuildContext context) {
    if (creators.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: AppSpacing.sectionPadding,
      child: Wrap(
        children: [
          Text(
            context.l10n.tvCreatedByLabel,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
          ),
          for (var i = 0; i < creators.length; i++) ...[
            if (i > 0)
              Text(
                ' · ',
                style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
              ),
            GestureDetector(
              onTap: () => onPersonTap?.call(creators[i]),
              child: Text(creators[i].name, style: AppTextStyles.bodySm),
            ),
          ],
        ],
      ),
    );
  }
}
