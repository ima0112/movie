import 'package:flutter/material.dart';

import '../../core/data/assets/collection_catalog_loader.dart';
import '../../core/domain/entities/collection.dart';
import '../../core/domain/entities/collection_catalog.dart';
import '../../core/domain/entities/media_type.dart';
import '../../core/theme/app_spacing.dart';
import '../../l10n/collection_localization.dart';
import '../../l10n/l10n_extension.dart';
import 'app_chip.dart';
import 'filter_section_header.dart';

/// H8's "Collection" section: the curated collections (Turkish series, Anime,
/// For kids…) that exist for the kind of title as single-select chips —
/// tapping the picked one again clears it. Nothing is drawn until the catalog
/// has loaded, nor when no collection exists for the kind of title.
class FilterCollectionChips extends StatelessWidget {
  const FilterCollectionChips({
    super.key,
    required this.type,
    required this.selected,
    required this.onChanged,
    this.catalog,
  });

  /// The kind of title; `null` (All) offers every collection.
  final MediaType? type;
  final Collection? selected;
  final ValueChanged<Collection?> onChanged;

  /// The catalog to offer; the bundled `assets/collections.json` when `null`.
  final Future<CollectionCatalog>? catalog;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CollectionCatalog>(
      future: catalog ?? loadCollectionCatalog(),
      builder: (context, snapshot) {
        final catalog = snapshot.data;
        if (catalog == null) return const SizedBox.shrink();
        final collections = type == null
            ? catalog.all()
            : catalog.availableFor(type!);
        if (collections.isEmpty) return const SizedBox.shrink();
        final l10n = context.l10n;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FilterSectionHeader(l10n.filterSheetSectionCollection),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final collection in collections)
                  AppChip(
                    label: collection.localizedName(l10n),
                    state: collection == selected
                        ? ChipState.selected
                        : ChipState.normal,
                    onTap: () =>
                        onChanged(collection == selected ? null : collection),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sectionGap),
          ],
        );
      },
    );
  }
}
