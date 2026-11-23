import 'package:flutter/material.dart';

import '../../../../core/domain/entities/season_summary.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import 'timeline_episode.dart';
import 'timeline_marker.dart';
import 'tv_status.dart';

/// D2b's one card for the episodes around today, as a vertical timeline: the
/// **next** episode on top (dashed marker) and the **last aired** under it
/// (amber marker and label). With no next episode the node says why — the show
/// ended, was cancelled, or none has been announced — and with no last aired
/// episode only the next node is drawn.
class SeasonsTimelineCard extends StatelessWidget {
  const SeasonsTimelineCard({
    super.key,
    required this.status,
    required this.nextEpisode,
    required this.lastEpisode,
  });

  /// TMDB's raw status string (see [tvStatusIsFinished]).
  final String status;
  final EpisodeRef? nextEpisode;
  final EpisodeRef? lastEpisode;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final next = nextEpisode;
    final last = lastEpisode;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Node(
            upcoming: true,
            label: l10n.tvTimelineNext,
            bottomGap: last != null,
            child: next != null
                ? TimelineEpisode(episode: next)
                : _NoNext(status: status),
          ),
          if (last != null)
            _Node(
              upcoming: false,
              label: l10n.tvTimelineLast,
              bottomGap: false,
              child: TimelineEpisode(episode: last),
            ),
        ],
      ),
    );
  }
}

/// One node: the marker column on the left (with its line) and, at the right,
/// the label over [child].
class _Node extends StatelessWidget {
  const _Node({
    required this.upcoming,
    required this.label,
    required this.child,
    required this.bottomGap,
  });

  final bool upcoming;
  final String label;
  final Widget child;
  final bool bottomGap;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TimelineMarker(upcoming: upcoming),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomGap ? AppSpacing.lg : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: upcoming
                        ? AppTextStyles.overline
                        : AppTextStyles.overline.copyWith(
                            color: AppColors.accent,
                          ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  child,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The next node with no episode: why there is none.
class _NoNext extends StatelessWidget {
  const _NoNext({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final body = switch (status) {
      'Ended' => l10n.tvNoNextEpisodeEnded,
      'Canceled' => l10n.tvNoNextEpisodeCancelled,
      _ => l10n.tvNoNextEpisodeUnknown,
    };
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.tvNoNextEpisodeTitle, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            body,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
          ),
        ],
      ),
    );
  }
}
