import 'package:flutter/material.dart';

import '../../../../core/domain/entities/user_media_entry.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// A single entry's contribution to the "Hours" sum, in minutes. Exactly
/// one of the two terms is ever non-zero for a given entry: movies only
/// ever have [UserMediaEntry.runtimeMinutes] set, TV entries only ever
/// have `episodeCount`/`episodeRuntimeMinutes` set — so adding both
/// unconditionally (with `?? 0` for whichever pair doesn't apply) is
/// equivalent to switching on the entry's `MediaKey.type`, without
/// needing to.
int _minutesFor(UserMediaEntry entry) =>
    (entry.runtimeMinutes ?? 0) +
    (entry.episodeCount ?? 0) * (entry.episodeRuntimeMinutes ?? 0);

/// B5 ("You")'s "Your Activity" card: four large numbers plus a link to
/// Stats.
///
/// Source of truth: `docs/SCREENS.md` B5 — "Your Activity card: four
/// large numbers (watched · hours · favorites · watch later) and an
/// amber 'See stats' link → C4. No charts." C4 doesn't exist yet, so
/// [onSeeStats] is a plain callback the not-yet-built `you_screen.dart`
/// will wire to that route later.
///
/// Reads [UserLibraryRepository.watch] directly (no filter = every
/// entry) rather than a Cubit of its own — CLAUDE.md rule 10 forbids a
/// My-List-wide Cubit caching the full list, and this card needs nothing
/// more than a live count over the same stream My List itself uses.
///
/// "Hours" sums each watched entry's [UserMediaEntry.runtimeMinutes]
/// (movies) or `episodeCount * episodeRuntimeMinutes` (TV, whole-show
/// estimate — TV is tracked at the whole-show level, never per episode),
/// divided by 60. A `null` field (an entry watched before that field
/// existed, or whose `MediaDetail` had no runtime from TMDB) contributes
/// `0` to the sum rather than throwing or being skipped — old data just
/// undercounts instead of breaking the card.
class YourActivityCard extends StatelessWidget {
  const YourActivityCard({
    super.key,
    required this.userLibraryRepository,
    required this.onSeeStats,
  });

  final UserLibraryRepository userLibraryRepository;

  /// → C4 ("Stats").
  final VoidCallback onSeeStats;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Activity', style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.md),
            StreamBuilder<List<UserMediaEntry>>(
              stream: userLibraryRepository.watch(),
              builder: (context, snapshot) {
                final entries = snapshot.data ?? const <UserMediaEntry>[];
                final watched = entries.where((e) => e.isWatched).length;
                final favorites = entries.where((e) => e.isFavorite).length;
                final watchLater = entries.where((e) => e.isWatchLater).length;
                final hours =
                    entries
                        .where((e) => e.isWatched)
                        .fold<int>(0, (sum, e) => sum + _minutesFor(e)) /
                    60;
                return Row(
                  children: [
                    Expanded(
                      child: _Metric(value: '$watched', label: 'Watched'),
                    ),
                    Expanded(
                      child: _Metric(value: '${hours.round()}', label: 'Hours'),
                    ),
                    Expanded(
                      child: _Metric(value: '$favorites', label: 'Favorites'),
                    ),
                    Expanded(
                      child: _Metric(
                        value: '$watchLater',
                        label: 'Watch later',
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: onSeeStats,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'See stats',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                  const Icon(
                    AppIcons.chevronRight,
                    size: 16,
                    color: AppColors.accent,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
        ),
      ],
    );
  }
}
