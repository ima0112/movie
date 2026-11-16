import 'package:flutter/material.dart';

import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_segmented_control.dart';

/// E2 step 4's "Limits" card: for a movie the longest it may run (a slider,
/// "No limit" at the far end), for a show whether it must be finished (Any |
/// Finished), then — for both — the "Exclude what I've already watched" switch.
///
/// Pure presentation — everything comes in by parameter.
class QuizLimitsCard extends StatelessWidget {
  const QuizLimitsCard({
    super.key,
    required this.mediaType,
    required this.maxRuntimeMinutes,
    required this.onMaxRuntimeChanged,
    required this.finishedOnly,
    required this.onFinishedOnlyChanged,
    required this.excludeWatched,
    required this.onExcludeWatchedChanged,
  });

  final MediaType mediaType;

  /// `null` = no limit.
  final int? maxRuntimeMinutes;
  final ValueChanged<int?> onMaxRuntimeChanged;
  final bool finishedOnly;
  final ValueChanged<bool> onFinishedOnlyChanged;
  final bool excludeWatched;
  final ValueChanged<bool> onExcludeWatchedChanged;

  /// The slider's scale in minutes, in [runtimeStep] steps; the top end means
  /// "no limit".
  static const int minRuntime = 60;
  static const int maxRuntime = 240;
  static const int runtimeStep = 5;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.lineStrong),
      ),
      child: Column(
        children: [
          if (mediaType == MediaType.movie)
            _DurationRow(
              minutes: maxRuntimeMinutes,
              onChanged: onMaxRuntimeChanged,
            )
          else
            _StatusRow(
              finishedOnly: finishedOnly,
              onChanged: onFinishedOnlyChanged,
            ),
          const Divider(height: 1, color: AppColors.line),
          _SwitchRow(
            label: context.l10n.quizExcludeWatchedToggle,
            value: excludeWatched,
            onChanged: onExcludeWatchedChanged,
          ),
        ],
      ),
    );
  }
}

class _DurationRow extends StatelessWidget {
  const _DurationRow({required this.minutes, required this.onChanged});

  final int? minutes;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final value = (minutes ?? QuizLimitsCard.maxRuntime).clamp(
      QuizLimitsCard.minRuntime,
      QuizLimitsCard.maxRuntime,
    );
    final isNoLimit = value >= QuizLimitsCard.maxRuntime;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.cardPadding,
        AppSpacing.md,
        AppSpacing.cardPadding,
        AppSpacing.xs,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(l10n.quizMaxDuration, style: AppTextStyles.bodySm),
              ),
              Text(
                isNoLimit
                    ? l10n.discoverRangeFiltersNoLimit
                    : formatRuntime(value, l10n),
                style: AppTextStyles.bodySmStrong.copyWith(
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.accent,
              inactiveTrackColor: AppColors.lineStrong,
              thumbColor: AppColors.ink,
              overlayColor: AppColors.ink.withValues(alpha: 0.12),
            ),
            child: Slider(
              value: value.toDouble(),
              min: QuizLimitsCard.minRuntime.toDouble(),
              max: QuizLimitsCard.maxRuntime.toDouble(),
              divisions:
                  (QuizLimitsCard.maxRuntime - QuizLimitsCard.minRuntime) ~/
                  QuizLimitsCard.runtimeStep,
              label: isNoLimit
                  ? l10n.discoverRangeFiltersNoLimit
                  : formatRuntime(value, l10n),
              onChanged: (v) => onChanged(
                v.round() >= QuizLimitsCard.maxRuntime ? null : v.round(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "2 h 30 min", "2 h", "90 min" — the slider's value, in the user's language.
String formatRuntime(int minutes, AppLocalizations l10n) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return l10n.discoverRangeFiltersMinutes(m);
  if (m == 0) return l10n.quizDurationHours(h);
  return l10n.quizDurationHoursMinutes(h, m);
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.finishedOnly, required this.onChanged});

  final bool finishedOnly;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.quizStatusLabel, style: AppTextStyles.bodySm),
          const SizedBox(height: AppSpacing.md),
          AppSegmentedControl<bool>(
            padding: EdgeInsets.zero,
            onSheet: true,
            segments: [
              AppSegment(value: false, label: l10n.quizStatusAny),
              AppSegment(value: true, label: l10n.quizStatusFinished),
            ],
            selected: finishedOnly,
            onSelected: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.cardPadding,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.bodySm)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.onAccent,
            activeTrackColor: AppColors.accent,
          ),
        ],
      ),
    );
  }
}
