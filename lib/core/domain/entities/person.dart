import 'media_item.dart';

/// Cast/crew list-level entry, and D3's own subject.
final class Person {
  const Person({
    required this.id,
    required this.name,
    required this.profilePath,
    this.knownForDepartment,
  });

  final int id;
  final String name;
  final String? profilePath;
  final String? knownForDepartment;
}

/// D3 (Person detail): [person] plus biography and their filmography.
final class PersonDetail {
  const PersonDetail({
    required this.person,
    required this.biography,
    required this.birthday,
    required this.deathday,
    required this.placeOfBirth,
    required this.credits,
  });

  final Person person;
  final String biography;
  final DateTime? birthday;
  final DateTime? deathday;
  final String? placeOfBirth;
  final List<MediaCredit> credits;
}

/// One row of a detail screen's cast list — grouped with [Person] per
/// CLAUDE.md rule 13: a trivial value object with no meaning outside
/// this context.
final class CastMember {
  const CastMember({
    required this.person,
    required this.character,
    required this.order,
  });

  final Person person;
  final String character;
  final int order;
}

/// One row of a detail screen's crew list (director, writer...).
final class CrewMember {
  const CrewMember({
    required this.person,
    required this.job,
    required this.department,
  });

  final Person person;
  final String job;
  final String department;
}

/// One row of [PersonDetail.credits] — a title they acted in ([character]
/// set) or worked on ([job] set).
final class MediaCredit {
  const MediaCredit({required this.item, this.character, this.job});

  final MediaItem item;
  final String? character;
  final String? job;
}
