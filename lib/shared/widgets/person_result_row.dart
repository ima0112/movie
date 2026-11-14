import 'package:flutter/material.dart';

import '../../core/domain/entities/person.dart';
import '../../l10n/l10n_extension.dart';
import 'profile_image.dart';
import 'search_result_tile.dart';

/// A person's result row: a round photo (their initial when there is none), the
/// name and "Department · Person".
class PersonResultRow extends StatelessWidget {
  const PersonResultRow({super.key, required this.person, required this.onTap});

  final Person person;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final department = person.knownForDepartment;
    return SearchResultTile(
      onTap: onTap,
      title: person.name,
      subtitle: department == null || department.isEmpty
          ? l10n.explorePersonLabel
          : l10n.explorePersonMetadata(department),
      // The same slot as a poster, so rows line up; the photo is round.
      leading: Center(
        child: ClipOval(
          child: SizedBox(
            width: SearchResultTile.leadingWidth,
            height: SearchResultTile.leadingWidth,
            child: ProfileImage(
              profilePath: person.profilePath,
              name: person.name,
            ),
          ),
        ),
      ),
    );
  }
}
