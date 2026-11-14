import 'package:flutter/material.dart';

import '../../../../core/domain/entities/genre.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/genre_icons.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/genre_multi_select_chips.dart';

/// Opens the picker of genres to avoid: every genre not already avoided;
/// tapping one calls [onPick] and closes the sheet. It opens on the root
/// navigator, over the page's floating bar.
Future<void> showTasteAddGenreSheet(
  BuildContext context, {
  required Set<Genre> avoided,
  required ValueChanged<Genre> onPick,
}) => showModalBottomSheet<void>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  builder: (sheetContext) => TasteAddGenreSheet(
    genres: [
      for (final (genre, _) in genreOptions)
        if (!avoided.contains(genre)) genre,
    ],
    onPick: (genre) {
      Navigator.of(sheetContext).pop();
      onPick(genre);
    },
  ),
);

/// The sheet's content: a title and the [genres] still available as chips.
class TasteAddGenreSheet extends StatelessWidget {
  const TasteAddGenreSheet({
    super.key,
    required this.genres,
    required this.onPick,
  });

  final List<Genre> genres;
  final ValueChanged<Genre> onPick;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenMargin,
          AppSpacing.sm,
          AppSpacing.screenMargin,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.myTastesAddAvoidedSheetTitle,
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: AppSpacing.lg),
            GenreMultiSelectChips(
              genres: genres,
              selected: const {},
              onToggle: onPick,
            ),
          ],
        ),
      ),
    );
  }
}
