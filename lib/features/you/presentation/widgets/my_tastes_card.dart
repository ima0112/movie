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
import 'my_tastes_invitation.dart';

/// B5's "My Tastes": a one-row card (a heart, the title, a line summarizing
/// the taste profile, a chevron) that opens C5, or the invitation card while
/// there is no taste profile (`docs/SCREENS.md` B5).
///
/// The summary names up to two liked genres and how many more, then the
/// vibes — "Drama, Science Fiction +2 · 3 vibes" — and falls back to a plain
/// description of what My Tastes holds when none are picked yet.
///
/// Subscribes to the global [TasteProfileCubit] — CLAUDE.md rule 10.
class MyTastesCard extends StatelessWidget {
  const MyTastesCard({super.key, required this.onTap});

  /// → C5 ("My Tastes"), for both the row and the invitation card.
  final VoidCallback onTap;

  /// How many liked genres the summary names before "+N".
  static const int namedGenres = 2;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: BlocBuilder<TasteProfileCubit, TasteProfile?>(
          builder: (context, profile) => profile == null
              ? MyTastesInvitation(onTap: onTap)
              : GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTap,
                  child: _Row(summary: summaryOf(profile, context.l10n)),
                ),
        ),
      ),
    );
  }

  /// e.g. "Drama, Science Fiction +2 · 3 vibes". Genres are ordered by id (a
  /// stable, locale-independent order, rule 15), and each part is left out
  /// when it is empty.
  static String summaryOf(TasteProfile profile, AppLocalizations l10n) {
    final genres = profile.likedGenres.toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    final names = genres
        .take(namedGenres)
        .map((g) => g.localizedName(l10n))
        .join(', ');
    final more = genres.length - namedGenres;
    final parts = [
      if (genres.isNotEmpty)
        more > 0 ? l10n.myTastesRowGenresMore(names, more) : names,
      if (profile.likedVibes.isNotEmpty)
        l10n.myTastesSummaryVibeCount(profile.likedVibes.length),
    ];
    return parts.isEmpty ? l10n.myTastesRowFallback : parts.join(' · ');
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(AppIcons.favorite, size: 24, color: AppColors.accent),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.myTastesTitle, style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                summary,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.inkMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const Icon(AppIcons.chevronRight, size: 20, color: AppColors.inkMuted),
      ],
    );
  }
}
