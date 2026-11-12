import 'package:flutter/material.dart';

import '../../../core/domain/entities/person.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// A one-line credit under the Cast heading — "Created by Chad Feehan",
/// "Directed by Christopher Nolan · …": a muted [label] (it carries its own
/// trailing space) and the tappable names separated by "·" (→ D3,
/// `docs/SCREENS.md` D1/D2). Renders nothing for an empty [people].
class MediaByline extends StatelessWidget {
  const MediaByline({
    super.key,
    required this.label,
    required this.people,
    this.onPersonTap,
  });

  final String label;
  final List<Person> people;
  final void Function(Person person)? onPersonTap;

  @override
  Widget build(BuildContext context) {
    if (people.isEmpty) return const SizedBox.shrink();

    final muted = AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted);
    return Wrap(
      children: [
        Text(label, style: muted),
        for (var i = 0; i < people.length; i++) ...[
          if (i > 0) Text(' · ', style: muted),
          GestureDetector(
            onTap: () => onPersonTap?.call(people[i]),
            child: Text(people[i].name, style: AppTextStyles.bodySm),
          ),
        ],
      ],
    );
  }
}
