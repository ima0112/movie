import 'package:flutter/material.dart';

import '../../../../core/domain/entities/user_media_entry.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

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
/// **"hours" is a known gap, not a bug**: neither `UserMediaEntry` nor
/// `UserMediaEntries` (its drift table) stores a title's runtime, so
/// there is no data this card could sum to produce a real hours figure
/// today. It renders as "—" until a later branch adds that column and
/// populates it from `MediaDetail.runtimeMinutes` — the other three
/// numbers are real, live counts.
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
                return Row(
                  children: [
                    Expanded(
                      child: _Metric(value: '$watched', label: 'Watched'),
                    ),
                    Expanded(
                      child: _Metric(value: '—', label: 'Hours'),
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
