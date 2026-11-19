import 'package:flutter/material.dart';

import '../../../../core/domain/entities/collection.dart';
import '../../../../core/domain/entities/collection_catalog.dart';
import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../l10n/collection_localization.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/accent_headline.dart';
import '../../../../shared/widgets/app_chip.dart';
import '../../../../shared/widgets/overline_label.dart';
import '../cubit/quiz_state.dart';

/// E2 step 1 — "Where should it **come from**?": the collections that exist
/// for the kind of title (Turkish series, Anime, For kids…), grouped by what
/// they are, as chips filled in amber — **up to [QuizState.maxCollections]**,
/// and none is fine: the search then comes from everything. Once the cap is
/// reached the rest dim and stop answering taps. Pure presentation.
class QuizCollectionStep extends StatelessWidget {
  const QuizCollectionStep({
    super.key,
    required this.collectionCatalog,
    required this.mediaType,
    required this.selected,
    required this.onToggle,
  });

  final CollectionCatalog collectionCatalog;
  final MediaType mediaType;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  static const double _disabledOpacity = 0.3;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final atMax = selected.length >= QuizState.maxCollections;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AccentHeadline(
          before: l10n.quizCollectionHeadlineBefore,
          accent: l10n.quizCollectionHeadlineAccent,
          after: l10n.quizCollectionHeadlineAfter,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.quizCollectionSubtitle,
          style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
        ),
        for (final group in CollectionGroup.values)
          ..._group(context, group, atMax),
      ],
    );
  }

  List<Widget> _group(BuildContext context, CollectionGroup group, bool atMax) {
    final collections = collectionCatalog.inGroup(group, mediaType);
    if (collections.isEmpty) return const [];
    final l10n = context.l10n;
    return [
      const SizedBox(height: AppSpacing.xl),
      OverlineLabel(_groupLabel(l10n, group)),
      const SizedBox(height: AppSpacing.md),
      Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.md,
        children: [
          for (final collection in collections)
            _chip(context, collection, atMax),
        ],
      ),
    ];
  }

  Widget _chip(BuildContext context, Collection collection, bool atMax) {
    final isSelected = selected.contains(collection.id);
    final disabled = atMax && !isSelected;
    final name = collection.localizedName(context.l10n);
    final chip = AppChip(
      label: name,
      state: isSelected ? ChipState.solid : ChipState.normal,
      onTap: disabled ? null : () => onToggle(collection.id),
    );
    return Semantics(
      button: true,
      selected: isSelected,
      enabled: !disabled,
      excludeSemantics: true,
      label: name,
      onTap: disabled ? null : () => onToggle(collection.id),
      child: disabled ? Opacity(opacity: _disabledOpacity, child: chip) : chip,
    );
  }

  static String _groupLabel(AppLocalizations l10n, CollectionGroup group) =>
      switch (group) {
        CollectionGroup.world => l10n.quizCollectionGroupWorld,
        CollectionGroup.format => l10n.quizCollectionGroupFormat,
        CollectionGroup.occasion => l10n.quizCollectionGroupOccasion,
      };
}
