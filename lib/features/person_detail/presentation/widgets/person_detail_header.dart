import 'package:flutter/material.dart';

import '../../../../core/domain/entities/person.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/profile_image.dart';
import '../../../../shared/widgets/scrim_back_button.dart';

/// D3's header — `docs/SCREENS.md` D3: "Large circular photo, name,
/// department..., 'Born: date · place'." This task refines that last
/// part: rather than the literal birth date, the header shows a
/// computed age/years-lived ([ageLabel], from `person_age_label.dart`)
/// and [placeOfBirth] on its own, with no raw date attached to either.
///
/// Pure presentation — [ageLabel] arrives pre-formatted, same reason
/// D1/D2's own headers take an already-built `metadataLine` rather than
/// formatting one themselves (CLAUDE.md rule 9: the assembling screen
/// already knows it's loaded).
class PersonDetailHeader extends StatelessWidget {
  const PersonDetailHeader({
    super.key,
    required this.person,
    required this.ageLabel,
    required this.placeOfBirth,
  });

  final Person person;
  final String? ageLabel;
  final String? placeOfBirth;

  static const double photoSize = 120;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.xxxl,
          ),
          child: Column(
            children: [
              // Clears the ScrimBackButton (top-left, 40 px + padding).
              const SizedBox(height: AppSpacing.xxxl),
              ClipOval(
                child: SizedBox(
                  width: photoSize,
                  height: photoSize,
                  child: ProfileImage(
                    profilePath: person.profilePath,
                    name: person.name,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                person.name,
                style: AppTextStyles.display,
                textAlign: TextAlign.center,
              ),
              if (person.knownForDepartment != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  person.knownForDepartment!,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
              if (ageLabel != null || placeOfBirth != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  [?ageLabel, ?placeOfBirth].join(' · '),
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.inkMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
        const ScrimBackButton(),
      ],
    );
  }
}
