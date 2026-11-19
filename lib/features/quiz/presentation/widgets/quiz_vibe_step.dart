import 'package:flutter/material.dart';

import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/vibe_localization.dart';
import '../../../../shared/widgets/accent_headline.dart';
import '../../../../shared/widgets/app_chip.dart';
import '../../../../shared/widgets/vibe_icon.dart';
import '../../../match_engine/domain/vibe.dart';
import '../../../match_engine/domain/vibe_catalog.dart';
import '../cubit/quiz_state.dart';

/// E2 step 2 — "Which **vibes** are you in the mood for today?": the vibes of
/// the chosen kind (16 for movies, 11 for TV) as chips with their icon, up to
/// [QuizState.maxVibes] filled in amber — none is fine, the search then goes
/// without vibes. Once the cap is reached the rest dim and stop answering
/// taps. Pure presentation.
class QuizVibeStep extends StatelessWidget {
  const QuizVibeStep({
    super.key,
    required this.vibeCatalog,
    required this.mediaType,
    required this.selected,
    this.options,
    required this.onToggle,
  });

  final VibeCatalog vibeCatalog;
  final MediaType mediaType;
  final Set<String> selected;

  /// The vibes to show; every one of [mediaType] when `null`.
  final List<Vibe>? options;
  final ValueChanged<String> onToggle;

  static const double _disabledOpacity = 0.3;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vibes = options ?? vibeCatalog.availableFor(mediaType);
    final atMax = selected.length >= QuizState.maxVibes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AccentHeadline(
          before: l10n.quizVibeHeadlineBefore,
          accent: l10n.quizVibeHeadlineAccent,
          after: l10n.quizVibeHeadlineAfter,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.quizVibeSubtitle,
          style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
        ),
        const SizedBox(height: AppSpacing.xl),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.md,
          children: [
            for (final vibe in vibes)
              () {
                final isSelected = selected.contains(vibe.id);
                final disabled = atMax && !isSelected;
                final name = vibe.localizedName(l10n);
                final chip = AppChip(
                  label: name,
                  icon: vibeIconFor(vibe),
                  state: isSelected ? ChipState.solid : ChipState.normal,
                  onTap: disabled ? null : () => onToggle(vibe.id),
                );
                return Semantics(
                  button: true,
                  selected: isSelected,
                  enabled: !disabled,
                  excludeSemantics: true,
                  label: name,
                  onTap: disabled ? null : () => onToggle(vibe.id),
                  child: disabled
                      ? Opacity(opacity: _disabledOpacity, child: chip)
                      : chip,
                );
              }(),
          ],
        ),
      ],
    );
  }
}
