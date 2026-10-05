import 'package:flutter/material.dart';

import '../../../../core/domain/entities/discover_filter.dart'
    show DiscoverTvStatus;
import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_chip.dart';
import '../../../../shared/widgets/discover_range_filters.dart'
    show MaxRuntimeFilter;
import 'quiz_max_seasons_stepper.dart';

/// E2 step 4 — `docs/SCREENS.md` E2: "Movie: 'Max runtime' slider
/// (60–240 min...). TV show: 'Finished | Either' toggle + 'Max seasons'
/// stepper (1–10, 'No limit'). Under both: a discreet 'Exclude what I've
/// already watched' toggle."
///
/// No conversational headline is given for this step in SCREENS.md
/// (unlike steps 1–3, each of which quotes one) — CLAUDE.md's rule
/// against inventing copy means this renders straight into the controls
/// rather than adding an invented sentence above them.
///
/// [mediaType] picks the branch; the *other* branch's value/callback
/// pair is unused and may be left `null` by the caller (a session's
/// `mediaType` never changes mid-quiz — see `QuizState`'s own doc
/// comment — so exactly one branch is ever actually live).
class QuizFinalStep extends StatelessWidget {
  const QuizFinalStep({
    super.key,
    required this.mediaType,
    this.maxRuntimeMinutes,
    this.onMaxRuntimeMinutesChanged,
    this.tvStatus,
    this.onTvStatusChanged,
    this.maxSeasons,
    this.onMaxSeasonsChanged,
    required this.excludeWatched,
    required this.onExcludeWatchedChanged,
  });

  final MediaType mediaType;

  /// Movie sessions only.
  final int? maxRuntimeMinutes;
  final ValueChanged<int?>? onMaxRuntimeMinutesChanged;

  /// TV sessions only.
  final DiscoverTvStatus? tvStatus;
  final ValueChanged<DiscoverTvStatus?>? onTvStatusChanged;
  final int? maxSeasons;
  final ValueChanged<int?>? onMaxSeasonsChanged;

  final bool excludeWatched;
  final ValueChanged<bool> onExcludeWatchedChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (mediaType == MediaType.movie)
          MaxRuntimeFilter(
            maxRuntimeMinutes: maxRuntimeMinutes,
            onChanged: onMaxRuntimeMinutesChanged!,
          )
        else ...[
          _FinishedOrEitherToggle(
            tvStatus: tvStatus,
            onChanged: onTvStatusChanged!,
          ),
          const SizedBox(height: AppSpacing.lg),
          MaxSeasonsStepper(
            maxSeasons: maxSeasons,
            onChanged: onMaxSeasonsChanged!,
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Exclude what I've already watched",
              style: AppTextStyles.body,
            ),
            Switch(
              value: excludeWatched,
              onChanged: onExcludeWatchedChanged,
              activeThumbColor: AppColors.accent,
            ),
          ],
        ),
      ],
    );
  }
}

/// "'Finished | Either' toggle" — two explicit, mutually-exclusive
/// choices (unlike H8's own `TvStatusToggle`, which offers Airing/Ended
/// with "tap again to clear" instead of a visible third "either" state).
/// `ParticipantAnswers.tvStatus`'s own doc comment already notes this
/// quiz never produces [DiscoverTvStatus.airing] — only `ended`
/// ("Finished") or `null` ("Either").
class _FinishedOrEitherToggle extends StatelessWidget {
  const _FinishedOrEitherToggle({
    required this.tvStatus,
    required this.onChanged,
  });

  final DiscoverTvStatus? tvStatus;
  final ValueChanged<DiscoverTvStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      children: [
        AppChip(
          label: 'Finished',
          state: tvStatus == DiscoverTvStatus.ended
              ? ChipState.selected
              : ChipState.normal,
          onTap: () => onChanged(DiscoverTvStatus.ended),
        ),
        AppChip(
          label: 'Either',
          state: tvStatus == null ? ChipState.selected : ChipState.normal,
          onTap: () => onChanged(null),
        ),
      ],
    );
  }
}
