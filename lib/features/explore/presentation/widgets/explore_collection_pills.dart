import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/data/assets/collection_catalog_loader.dart';
import '../../../../core/domain/entities/collection.dart';
import '../../../../core/domain/entities/collection_catalog.dart';
import '../../../../core/domain/entities/media_type.dart';
import '../../../../l10n/collection_localization.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_section.dart';
import '../cubit/explore_browse_cubit.dart';
import '../cubit/explore_browse_state.dart';
import 'explore_pill.dart';
import 'explore_pill_row.dart';

/// B2's "COLLECTION" row: an "All" pill and the curated collections that exist
/// for the segment (Turkish series only with All and TV Shows, Bollywood only
/// with All and Movies, Anime in both), single select, in the catalog's order.
/// Watches only the picked collection and the segment's kind of title
/// (CLAUDE.md rule 9). Nothing is drawn until the catalog has loaded.
class ExploreCollectionPills extends StatelessWidget {
  const ExploreCollectionPills({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CollectionCatalog>(
      future: loadCollectionCatalog(),
      builder: (context, snapshot) {
        final catalog = snapshot.data;
        if (catalog == null) return const SizedBox.shrink();
        final l10n = context.l10n;
        return AppSection.overline(
          title: l10n.exploreCollectionLabel,
          inset: false,
          child:
              BlocSelector<
                ExploreBrowseCubit,
                ExploreBrowseState,
                (Collection?, MediaType?)
              >(
                selector: (state) =>
                    (state.collection, state.segment.mediaType),
                builder: (context, current) {
                  final (picked, type) = current;
                  final cubit = context.read<ExploreBrowseCubit>();
                  return ExplorePillRow(
                    pills: [
                      ExplorePill(
                        label: l10n.exploreCollectionAll,
                        selected: picked == null,
                        onTap: () => cubit.selectCollection(null),
                      ),
                      for (final collection in _shownFor(catalog, type))
                        ExplorePill(
                          label: collection.localizedName(l10n),
                          selected: picked == collection,
                          onTap: () => cubit.selectCollection(collection),
                        ),
                    ],
                  );
                },
              ),
        );
      },
    );
  }

  /// With "All" every collection (each exists for at least one kind of title);
  /// with a kind, those that exist for it.
  static List<Collection> _shownFor(
    CollectionCatalog catalog,
    MediaType? type,
  ) => type == null ? catalog.all() : catalog.availableFor(type);
}
