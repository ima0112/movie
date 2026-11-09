import 'package:flutter/material.dart';

import '../../../../core/domain/entities/person.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/filmography_segment_localization.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_section.dart';
import '../../../../shared/widgets/app_segmented_control.dart';
import 'filmography_grouping.dart';
import 'person_filmography_row.dart';

/// D3b's "Filmography" — `docs/SCREENS.md` D3b: tabs (All · Movies · TV
/// Shows · As director — each only when it would show something different
/// from All) and a newest-first list of rows (poster, title, "role · year",
/// ★ rating). No infinite scroll — [credits] is the full list TMDB's one
/// combined-credits call already returned.
///
/// The selected tab is local widget state, not `PersonDetailCubit` state —
/// same CLAUDE.md rule 10 reasoning `ExpandableText`'s expand follows: it
/// has no meaning beyond this one widget's lifetime.
class PersonFilmographySection extends StatefulWidget {
  const PersonFilmographySection({
    super.key,
    required this.credits,
    this.onCreditTap,
    this.showTitle = true,
  });

  final List<MediaCredit> credits;
  final void Function(MediaCredit credit)? onCreditTap;

  /// D3b has the person's name as its screen title, so it hides the
  /// section's own "Filmography" heading.
  final bool showTitle;

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
    final available = widget.credits.availableSegments;
    final rows = widget.credits.filteredBy(_segment).newestFirst;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // One tab ("All" alone) would be a pointless control.
        if (available.length > 1) ...[
          AppSegmentedControl<FilmographySegment>(
            segments: [
              for (final segment in available)
                AppSegment(value: segment, label: segment.localizedLabel(l10n)),
            ],
            selected: available.contains(_segment)
                ? _segment
                : FilmographySegment.all,
            onSelected: (segment) => setState(() => _segment = segment),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenMargin,
          ),
          child: Column(
            children: [
              for (final credit in rows)
                PersonFilmographyRow(
                  credit: credit,
                  onTap: () => widget.onCreditTap?.call(credit),
                ),
            ],
          ),
        ),
      ],
    );
    // On D3b (no title of its own) the tabs sit just under the app bar.
    return widget.showTitle
        ? AppSection(
            title: l10n.personFilmographyTitle,
            inset: false,
            child: content,
          )
        : Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: content,
          );
  }
}
