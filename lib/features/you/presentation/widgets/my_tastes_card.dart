import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/cubits/taste_profile_cubit.dart';
import '../../../../core/domain/entities/taste_profile.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/genre_localization.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_chip.dart';
import 'my_tastes_invitation.dart';

/// Max liked-genre chips shown before collapsing the rest into a "+N"
/// chip — SCREENS.md B5: "liked genres as small chips (max 3 + '+N')".
const int _maxGenreChips = 3;

/// B5 ("You")'s "My Tastes" card: liked genres + a one-line summary when
/// a taste profile exists, or an invitation card when it doesn't.
///
/// Source of truth: `docs/SCREENS.md` B5 — "My Tastes card
/// (`surfaceRaised`, radius 14): liked genres as small chips (max 3 +
/// '+N'), line '3 vibes · since 1990 · never Horror'; tap → C5. No taste
/// profile: the invitation card with a small Pako and a 'My Tastes'
/// button." C5 doesn't exist yet, so [onTap] is a plain callback the
/// not-yet-built `you_screen.dart` will wire to that route later.
///
/// This card's radius uses [AppSpacing.radiusMd] (12), not a literal 14
/// — no token for 14 exists, and [MetricCard]'s own card (built earlier
/// for the same kind of B5/C4 surface) already established `radiusMd` as
/// this codebase's answer for "card radius" (rule 4: never hardcode a
/// one-off).
///
/// Subscribes to the global [TasteProfileCubit] — CLAUDE.md rule 10.
class MyTastesCard extends StatelessWidget {
  const MyTastesCard({super.key, required this.onTap});

  /// → C5 ("My Tastes"), for both the built card and the invitation one.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: BlocBuilder<TasteProfileCubit, TasteProfile?>(
          builder: (context, profile) => profile == null
              ? MyTastesInvitation(onTap: onTap)
              : GestureDetector(
                  onTap: onTap,
                  child: _Summary(profile: profile),
                ),
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.profile});

  final TasteProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Sorted by id, not localized name — a stable, locale-independent
    // order (CLAUDE.md rule 15: domain data never drives display-text
    // ordering).
    final genres = profile.likedGenres.toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    final shown = genres.take(_maxGenreChips).toList();
    final overflow = genres.length - shown.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(l10n.myTastesTitle, style: AppTextStyles.h3)),
            const Icon(
              AppIcons.chevronRight,
              size: 20,
              color: AppColors.inkMuted,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final genre in shown)
              AppChip(label: genre.localizedName(l10n)),
            if (overflow > 0) AppChip(label: '+$overflow'),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          _summaryLine(profile, l10n),
          style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
        ),
      ],
    );
  }

  /// e.g. "3 vibes · since 1990 · never Horror" (SCREENS.md B5's literal
  /// example). SCREENS.md doesn't say what to do with zero or multiple
  /// vetoed genres — dropping the "never" clause when empty, and naming
  /// just the (id-order) first one when there's more than one, is this
  /// widget's own reasonable default for that gap, not a documented rule.
  static String _summaryLine(TasteProfile profile, AppLocalizations l10n) {
    final parts = <String>[
      l10n.myTastesSummaryVibeCount(profile.likedVibes.length),
      l10n.myTastesSummarySinceYear(profile.yearFrom),
    ];
    if (profile.vetoedGenres.isNotEmpty) {
      final firstVetoed =
          (profile.vetoedGenres.toList()..sort((a, b) => a.id.compareTo(b.id)))
              .first;
      parts.add(
        l10n.myTastesSummaryNeverGenre(firstVetoed.localizedName(l10n)),
      );
    }
    return parts.join(' · ');
  }
}
