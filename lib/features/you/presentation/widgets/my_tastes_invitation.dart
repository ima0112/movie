import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/pako_state.dart';

/// [MyTastesCard]'s empty state — "No taste profile: the invitation card
/// with a small Pako and a 'My Tastes' button" (`docs/SCREENS.md` B5).
/// Only the button's label is given verbatim by that doc; the headline
/// and supporting line here are this widget's own copy, not a quote from
/// SCREENS.md.
///
/// Split into its own file (rather than a private class inside
/// `my_tastes_card.dart`) purely to keep that file under CLAUDE.md rule
/// 11's 150-line soft limit — same reasoning as
/// `rating_stars_selector.dart`'s split out of `mark_as_watched_sheet.dart`.
class MyTastesInvitation extends StatelessWidget {
  const MyTastesInvitation({super.key, required this.onTap});

  /// → C5 ("My Tastes").
  final VoidCallback onTap;

  static const double _pakoSize = 56;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        const PakoState(mood: PakoMood.idle, size: _pakoSize),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.myTastesInvitationTitle,
          style: AppTextStyles.h3,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.myTastesInvitationBody,
          style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),
        SecondaryButton(
          label: l10n.myTastesTitle,
          onTap: onTap,
          fullWidth: false,
        ),
      ],
    );
  }
}
