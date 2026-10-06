import 'package:flutter/material.dart';

import '../../../../core/domain/entities/season_summary.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/still_image.dart';

/// One H4 episode row — `docs/SCREENS.md` H4: "episode list (number,
/// name, runtime, date, still)". A 16:9 still, "N. Title", a date/
/// duration line (date in amber if the episode hasn't aired yet), and
/// the episode's own synopsis folded to 2 lines with a tap-to-expand —
/// the same "fold, expand on tap" idea `MediaSynopsisSection` already
/// uses for D1/D2's own synopsis, just smaller (2 lines, not 4) and
/// local to this one row rather than the whole screen.
class SeasonEpisodeRow extends StatefulWidget {
  const SeasonEpisodeRow({super.key, required this.episode});

  final Episode episode;

  @override
  State<SeasonEpisodeRow> createState() => _SeasonEpisodeRowState();
}

class _SeasonEpisodeRowState extends State<SeasonEpisodeRow> {
  static const int _foldedMaxLines = 2;

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final episode = widget.episode;
    final airDate = episode.airDate;
    final hasAired = airDate == null || !airDate.isAfter(DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: StillImage(stillPath: episode.stillPath),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${episode.episodeNumber}. ${episode.name}',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Text(
                airDate == null ? 'TBA' : _formatDate(airDate),
                style: AppTextStyles.bodySm.copyWith(
                  color: hasAired ? AppColors.inkMuted : AppColors.accent,
                ),
              ),
              if (episode.runtimeMinutes != null) ...[
                Text(
                  ' · ',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
                Text(
                  '${episode.runtimeMinutes} min',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ],
          ),
          if (episode.overview.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              episode.overview,
              style: AppTextStyles.bodySm,
              maxLines: _expanded ? null : _foldedMaxLines,
              overflow: _expanded ? null : TextOverflow.ellipsis,
            ),
            if (!_expanded) ...[
              const SizedBox(height: AppSpacing.xs),
              GestureDetector(
                onTap: () => setState(() => _expanded = true),
                child: Text(
                  'Read more',
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.accent),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
