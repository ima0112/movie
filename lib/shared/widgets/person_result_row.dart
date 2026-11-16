import 'package:flutter/material.dart';

import '../../core/domain/entities/person.dart';
import '../../l10n/l10n_extension.dart';
import '../../l10n/app_localizations.dart';
import 'profile_image.dart';
import 'row_more_button.dart';
import 'search_result_tile.dart';

/// A person's result row: a round photo (their initial when there is none), the
/// name and "Department · Person".
class PersonResultRow extends StatelessWidget {
  const PersonResultRow({
    super.key,
    required this.person,
    required this.onTap,
    this.onMore,
    this.onLongPress,
  });

  final Person person;
  final VoidCallback onTap;

  /// A three-dot button in place of the chevron (My List's People tab).
  final VoidCallback? onMore;
  final VoidCallback? onLongPress;

  /// "Department · Person", or "Person" with no known department.
  static String subtitleOf(Person person, AppLocalizations l10n) {
    final department = person.knownForDepartment;
    return department == null || department.isEmpty
        ? l10n.explorePersonLabel
        : l10n.explorePersonMetadata(department);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SearchResultTile(
      onTap: onTap,
      title: person.name,
      onLongPress: onLongPress,
      trailing: onMore == null ? null : RowMoreButton(onTap: onMore!),
      subtitle: subtitleOf(person, l10n),
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
