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

  static const double photoSize = 112;

  // `accentDeep` at this opacity, fading to the page color — the warm
  // glow behind the header in the "Persona" design.
  static const double _glowOpacity = 0.3;

  List<String> get _details => [
    ?person.knownForDepartment,
    ?ageLabel,
    ?placeOfBirth,
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.accentDeep.withValues(alpha: _glowOpacity),
            AppColors.surface,
          ],
        ),
      ),
      child: Stack(
        children: [
          Padding(
            // Starts below the back button's row (status bar + button), and
            // adds no space below: the section after the header owns the gap
            // above it.
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screenMargin,
              MediaQuery.paddingOf(context).top +
                  ScrimBackButton.footprint +
                  AppSpacing.sm,
              AppSpacing.screenMargin,
              0,
            ),
            child: Column(
              // A Stack hands its child *loose* constraints, so without this
              // the column shrinks to its widest line and sits at the left.
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: ClipOval(
                    child: SizedBox(
                      width: photoSize,
                      height: photoSize,
                      child: ProfileImage(
                        profilePath: person.profilePath,
                        name: person.name,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  person.name,
                  style: AppTextStyles.h1,
                  textAlign: TextAlign.center,
                ),
                // "Acting · 51 years old · Los Angeles, USA" on one line, as
                // in the design.
                if (_details.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _details.join(' · '),
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
      ),
    );
  }
}
