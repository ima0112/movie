import 'package:flutter/material.dart';

import '../../../../core/domain/entities/person.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// [MovieCastRow]'s "Director and writer" line — tappable names separated
/// by "·" (SCREENS.md D1). In its own file per rule 11:
/// `movie_cast_row.dart` was over the 150-line target on its own.
class MovieCrewLine extends StatelessWidget {
  const MovieCrewLine({super.key, required this.crew, this.onPersonTap});

  final List<CrewMember> crew;
  final void Function(Person person)? onPersonTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        for (var i = 0; i < crew.length; i++) ...[
          if (i > 0)
            Text(
              ' · ',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
            ),
          GestureDetector(
            onTap: () => onPersonTap?.call(crew[i].person),
            child: Text(
              '${crew[i].person.name} (${crew[i].job})',
              style: AppTextStyles.bodySm,
            ),
          ),
        ],
      ],
    );
  }
}
