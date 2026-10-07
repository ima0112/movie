import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di.dart';
import '../../../../app/router.dart';
import '../../../../core/domain/entities/genre.dart';
import '../../../../core/domain/entities/media_key.dart';
import '../../../../core/domain/entities/user_media_entry.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../cubit/surprise_cubit.dart';
import '../cubit/surprise_state.dart';
import 'surprise_result_card.dart';

/// E3's own loaded result — `docs/SCREENS.md` E3: headline, subtitle
/// (per [SurpriseResult.source]), the result card, an optional
/// relaxation note, and the two action buttons.
///
/// Deliberately **not built**: "Save these answers as my tastes?" (E3's
/// own "if it came from the quiz and there's no profile" link). Doing
/// this properly needs a `ParticipantAnswers` → `TasteProfile` reverse
/// mapping that doesn't exist anywhere — `TasteProfileBuilder` only goes
/// the other direction, and `ParticipantAnswers` carries no
/// `likedGenres` equivalent to reconstruct a full `TasteProfile` from
/// (only `excludedGenres`/`vibeIds`). Left as a documented TODO per this
/// branch's own task, rather than inventing a lossy mapping now.
class SurpriseResultContent extends StatelessWidget {
  const SurpriseResultContent({super.key, required this.state});

  final SurpriseResult state;

  @override
  Widget build(BuildContext context) {
    final item = state.current;
    final subtitle = switch (state.source) {
      SuggestionSource.profile => 'Based on your tastes',
      SuggestionSource.inferredList => 'Based on your list',
      SuggestionSource.quiz => null,
    };

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your suggestion', style: AppTextStyles.h1),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          SurpriseResultCard(
            item: item,
            onViewDetails: () => context.pushMediaDetail(item.key),
          ),
          if (state.relaxationsApplied.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            // E3's own "We widened the search to 1990" is this specific
            // — MatchResult only carries *which* Relaxation steps fired,
            // not the final widened value, so this stays a generic note
            // rather than a fabricated number.
            // TODO: thread the final MatchQuery's own yearFrom through
            // MatchResult so this can show the real figure.
            Text(
              'We broadened the search a bit to find this match.',
              style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: 'Add to Watch later',
            onTap: () =>
                _addToWatchLater(context, item.key, item.title, item.genres),
          ),
          const SizedBox(height: AppSpacing.md),
          SecondaryButton(
            label: 'Another suggestion',
            onTap: () => context.read<SurpriseCubit>().another(),
          ),
        ],
      ),
    );
  }

  Future<void> _addToWatchLater(
    BuildContext context,
    MediaKey key,
    String title,
    List<Genre> genres,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    await getIt<UserLibraryRepository>().upsert(
      UserMediaEntry(
        key: key,
        title: title,
        isWatchLater: true,
        genres: genres,
      ),
    );
    messenger.showSnackBar(
      const SnackBar(content: Text('Added to Watch later')),
    );
  }
}
