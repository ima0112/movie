import 'package:flutter/material.dart';

import '../../../../core/domain/entities/discover_filter.dart'
    show DiscoverTvStatus;
import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/accent_headline.dart';
import '../../../../shared/widgets/app_section.dart';
import '../../../../shared/widgets/release_range_picker.dart';
import '../../domain/typical_release_counts.dart';
import '../cubit/quiz_state.dart';
import 'quiz_limits_card.dart';

/// E2 step 4 — "Which **years**?": the release-range picker (cards, histogram,
/// two-handle slider, presets) and, under "Limits", the longest runtime (or
/// the status, for a show) and "Exclude what I've already watched".
///
/// The histogram is a fixed typical shape (`typicalReleaseCounts`), not the
/// user's list: it only gives the control some relief. Pure presentation —
/// the cubit's state comes in by parameter.
class QuizYearLimitsStep extends StatelessWidget {
  const QuizYearLimitsStep({
    super.key,
    required this.mediaType,
    required this.yearFrom,
    required this.yearTo,
    required this.onYearRangeChanged,
    required this.maxRuntimeMinutes,
    required this.onMaxRuntimeChanged,
    required this.tvStatus,
    required this.onTvStatusChanged,
    required this.excludeWatched,
    required this.onExcludeWatchedChanged,
    this.currentYear,
  });

  final MediaType mediaType;
  final int yearFrom;

  /// `null` = up to today.
  final int? yearTo;

  /// The picker's two handles, plus the current year ("Today" is its top end).
  final void Function(int from, int to, int currentYear) onYearRangeChanged;
  final int? maxRuntimeMinutes;
  final ValueChanged<int?> onMaxRuntimeChanged;
  final DiscoverTvStatus? tvStatus;
  final ValueChanged<DiscoverTvStatus?> onTvStatusChanged;
  final bool excludeWatched;
  final ValueChanged<bool> onExcludeWatchedChanged;

  /// `null` = read it from the clock; tests pass a fixed one.
  final int? currentYear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final now = currentYear ?? DateTime.now().year;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AccentHeadline(
          before: l10n.quizYearHeadlineBefore,
          accent: l10n.quizYearHeadlineAccent,
          after: l10n.quizYearHeadlineAfter,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.quizYearSubtitle,
          style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
        ),
        const SizedBox(height: AppSpacing.xl),
        ReleaseRangePicker(
          from: yearFrom,
          to: yearTo ?? now,
          minYear: QuizState.minYear,
          maxYear: now,
          counts: typicalReleaseCounts(
            minYear: QuizState.minYear,
            maxYear: now,
          ),
          onChanged: (from, to) => onYearRangeChanged(from, to, now),
        ),
        AppSection(
          title: l10n.quizLimitsTitle,
          inset: false,
          child: QuizLimitsCard(
            mediaType: mediaType,
            maxRuntimeMinutes: maxRuntimeMinutes,
            onMaxRuntimeChanged: onMaxRuntimeChanged,
            finishedOnly: tvStatus == DiscoverTvStatus.ended,
            onFinishedOnlyChanged: (finished) =>
                onTvStatusChanged(finished ? DiscoverTvStatus.ended : null),
            excludeWatched: excludeWatched,
            onExcludeWatchedChanged: onExcludeWatchedChanged,
          ),
        ),
      ],
    );
  }
}
