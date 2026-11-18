import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/genre_localization.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../cubit/surprise_cubit.dart';
import '../cubit/surprise_state.dart';

/// H11 (Choose source) — `docs/SCREENS.md` H11, opened from E1's own
/// `BlocListener` once [SurpriseCubit] emits [ChooseSource] (usable
/// tastes exist — an explicit profile, or one inferred from My List).
///
/// "Find something to watch"; a subtitle that names the user's liked genres
/// when the source is the profile (nothing under the title for a list the
/// app inferred); "Use my tastes" (primary) / "Answer the quiz instead"
/// (secondary); and, for the profile, the note that the quiz leaves the
/// saved tastes alone.
///
/// CLAUDE.md rule 9: this widget only ever reads the one [ChooseSource]
/// value its caller hands it — it never subscribes to [SurpriseCubit]
/// itself.
class ChooseSourceSheet extends StatelessWidget {
  const ChooseSourceSheet({super.key, required this.state});

  final ChooseSource state;

  /// How many genre names the subtitle spells out.
  static const int namedGenres = 3;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final subtitle = _subtitle(l10n);
    final isProfile = state.source == SuggestionSource.profile;
    final cubit = context.read<SurpriseCubit>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.surpriseChooseSourceTitle, style: AppTextStyles.h2),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: l10n.surpriseUseMyTastes,
              onTap: () {
                cubit.useMyTastes();
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: AppSpacing.md),
            SecondaryButton(
              label: l10n.surpriseAnswerQuizInstead,
              onTap: () {
                cubit.answerQuizInstead();
                Navigator.of(context).pop();
              },
            ),
            if (isProfile) ...[
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: Text(
                  l10n.surpriseQuizNote,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// The profile's liked genres by name ("Crime, Sci-Fi and Thriller"), or
  /// the generic "Based on your tastes" when it has none (only vibes);
  /// `null` for an inferred list — nothing to say under the title.
  String? _subtitle(AppLocalizations l10n) {
    if (state.source != SuggestionSource.profile) return null;
    final genres = state.tasteGenres.toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    if (genres.isEmpty) return l10n.surpriseSourceProfile;
    final names = genres
        .take(namedGenres)
        .map((g) => g.localizedName(l10n))
        .toList();
    final more = genres.length - namedGenres;
    final joined = more > 0
        ? l10n.myTastesRowGenresMore(names.join(', '), more)
        : names.length == 1
        ? names.single
        : l10n.surpriseGenresAnd(
            names.sublist(0, names.length - 1).join(', '),
            names.last,
          );
    return l10n.surpriseSourceProfileGenres(joined);
  }
}
