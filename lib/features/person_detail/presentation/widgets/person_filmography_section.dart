import 'package:flutter/material.dart';

import '../../../../core/domain/entities/person.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import 'filmography_grouping.dart';
import 'person_filmography_row.dart';
import 'person_filmography_segmented_control.dart';

/// D3's "Filmography" — `docs/SCREENS.md` D3: "filter chips All ·
/// Movies · TV Shows; reverse-chronological list (thumbnail, title,
/// year, role)", grouped by year per this task's own refinement
/// (`FilmographyYearGroup`). No infinite scroll (this task's own
/// note) — [credits] is the full list TMDB's one combined-credits call
/// already returned, so there's nothing to page in.
///
/// The selected segment is local widget state, not `PersonDetailCubit`
/// state — same CLAUDE.md rule 10 reasoning `MediaSynopsisSection`'s
/// own "read more" expand already follows: it has no meaning beyond
/// this one widget's lifetime.
class PersonFilmographySection extends StatefulWidget {
  const PersonFilmographySection({
    super.key,
    required this.credits,
    this.onCreditTap,
  });

  final List<MediaCredit> credits;
  final void Function(MediaCredit credit)? onCreditTap;

  @override
  State<PersonFilmographySection> createState() =>
      _PersonFilmographySectionState();
}

class _PersonFilmographySectionState extends State<PersonFilmographySection> {
  FilmographySegment _segment = FilmographySegment.all;

  @override
  Widget build(BuildContext context) {
    if (widget.credits.isEmpty) return const SizedBox.shrink();

    final l10n = context.l10n;
    final showAsDirector = widget.credits.hasBothCastAndCrew;
    final groups = widget.credits.filteredBy(_segment).groupedByYear;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(l10n.personFilmographyTitle, style: AppTextStyles.h2),
          ),
          const SizedBox(height: AppSpacing.md),
          PersonFilmographySegmentedControl(
            segment: _segment,
            showAsDirector: showAsDirector,
            onSelected: (segment) => setState(() => _segment = segment),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final group in groups) ...[
                  Text(
                    group.year == null
                        ? l10n.personFilmographyComingSoon
                        : '${group.year}',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.inkMuted,
                    ),
                  ),
                  for (final credit in group.credits)
                    PersonFilmographyRow(
                      credit: credit,
                      onTap: () => widget.onCreditTap?.call(credit),
                    ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
