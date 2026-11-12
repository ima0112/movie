import 'package:flutter/material.dart';

import '../../../core/domain/entities/person.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/l10n_extension.dart';
import '../app_section.dart';
import 'media_cast_circle.dart';

/// D1/D2's cast circles + the director/writer line.
///
/// Source of truth: `docs/SCREENS.md` D1 ("Cast: 10 circles at 64 px with
/// name and character... Director and writer: tappable names separated
/// by '·'"), reused unchanged by D2. Both → D3 (Person detail, not built
/// yet) — [onPersonTap] lets the assembled screen wire that once it
/// exists. Pure presentation — [cast]/[crew] arrive as plain values; no
/// Bloc subscription of its own (CLAUDE.md rule 9 — the assembling
/// screen already knows it's loaded).
class MediaCastRow extends StatelessWidget {
  const MediaCastRow({
    super.key,
    required this.cast,
    required this.crew,
    this.onPersonTap,
    this.onSeeFullCastTap,
    this.byline,
  });

  final List<CastMember> cast;
  final List<CrewMember> crew;
  final void Function(Person person)? onPersonTap;

  /// "See full cast" → H3 (not built yet).
  final VoidCallback? onSeeFullCastTap;

  /// A credit line between the heading and the circles (`MediaByline`:
  /// "Created by ..." / "Directed by ...").
  final Widget? byline;

  static const double _circleSize = 64;
  static const int _visibleCount = 10;

  @override
  Widget build(BuildContext context) {
    if (cast.isEmpty) return const SizedBox.shrink();

    final visibleCast = cast.take(_visibleCount).toList();
    return AppSection(
      title: context.l10n.fullCastCastLabel,
      // The full page also has the Crew tab, so there is "more" whenever there
      // are more than the circles shown, or any crew at all.
      actionLabel: cast.length > _visibleCount || crew.isNotEmpty
          ? context.l10n.discoverSeeAll
          : null,
      onAction: onSeeFullCastTap,
      inset: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (byline != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenMargin,
              ),
              child: byline,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          SizedBox(
            // Avatar + gap + two lines of `caption` (name, character) —
            // `xxl` alone (used for the "See full cast"/crew spacing
            // elsewhere) isn't tall enough for two lines and overflowed
            // by ~10px; `xxxl + sm` covers it with margin.
            height: _circleSize + AppSpacing.xxxl + AppSpacing.sm,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenMargin,
              ),
              scrollDirection: Axis.horizontal,
              itemCount: visibleCast.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: AppSpacing.md),
              itemBuilder: (context, index) {
                final member = visibleCast[index];
                return MediaCastCircle(
                  member: member,
                  size: _circleSize,
                  onTap: () => onPersonTap?.call(member.person),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
