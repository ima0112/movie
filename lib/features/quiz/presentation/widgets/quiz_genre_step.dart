import 'package:flutter/material.dart';

import '../../../../core/domain/entities/genre.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/genre_icons.dart';
import '../../../../l10n/genre_localization.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/accent_headline.dart';
import '../../../../shared/widgets/app_chip.dart';
import '../cubit/quiz_state.dart';

/// E2 step 1 — "What **NOT** are you in the mood for today?": the genres as
/// chips that flow, up to [QuizState.maxExcludedGenres] of them struck out in
/// red. Once the cap is reached the rest dim and stop answering taps (a tap on
/// a struck one still takes it back out). Pure presentation.
class QuizGenreStep extends StatelessWidget {
  const QuizGenreStep({
    super.key,
    required this.selected,
    required this.onToggle,
  });

  final Set<Genre> selected;
  final ValueChanged<Genre> onToggle;

  /// A disabled chip is shown at this opacity (the quiz tiles' own 30%).
  static const double _disabledOpacity = 0.3;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final atMax = selected.length >= QuizState.maxExcludedGenres;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AccentHeadline(
          before: l10n.quizGenreHeadlineBefore,
          accent: l10n.quizGenreHeadlineAccent,
          after: l10n.quizGenreHeadlineAfter,
          accentColor: AppColors.danger,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.quizGenreSubtitle,
          style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
        ),
        const SizedBox(height: AppSpacing.xl),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.md,
          children: [
            for (final (genre, _) in genreOptions)
              _chip(context, genre, selected.contains(genre), atMax),
          ],
        ),
      ],
    );
  }

  Widget _chip(BuildContext context, Genre genre, bool isSelected, bool atMax) {
    final disabled = atMax && !isSelected;
    final chip = AppChip(
      label: genre.localizedName(context.l10n),
      state: isSelected ? ChipState.vetoed : ChipState.normal,
      onTap: disabled ? null : () => onToggle(genre),
    );
    return Semantics(
      button: true,
      selected: isSelected,
      enabled: !disabled,
      excludeSemantics: true,
      label: genre.localizedName(context.l10n),
      onTap: disabled ? null : () => onToggle(genre),
      child: disabled ? Opacity(opacity: _disabledOpacity, child: chip) : chip,
    );
  }
}
