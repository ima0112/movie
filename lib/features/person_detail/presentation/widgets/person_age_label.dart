import '../../../../core/domain/entities/person.dart';
import '../../../../l10n/app_localizations.dart';
import 'person_age.dart';

/// D3's header age line — "{N} years old" while alive, "Lived {N}
/// years" once there's a [PersonDetail.deathday]. `null` when
/// [PersonDetail.birthday] itself is unknown (nothing to show).
///
/// Kept separate from [personAge] itself so that pure number is
/// independently testable (this task's own "test del cálculo de
/// edad") without also pinning down this exact copy.
String? personAgeLabel(PersonDetail detail, AppLocalizations l10n) {
  final age = personAge(detail.birthday, detail.deathday);
  if (age == null) return null;
  return detail.deathday != null
      ? l10n.personAgeLivedYears(age)
      : l10n.personAgeYearsOld(age);
}
