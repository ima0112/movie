import '../core/domain/entities/collection.dart';
import 'app_localizations.dart';

/// The single mapper from a [Collection]'s stable [Collection.id] to its
/// display name (CLAUDE.md rule 15). A runtime string switch, like
/// `VibeLocalization`: a collection added to `assets/collections.json`
/// without a case here fails at the first attempt to show its label.
extension CollectionLocalization on Collection {
  String localizedName(AppLocalizations l10n) => switch (id) {
    'turkish_series' => l10n.collectionTurkishSeries,
    'spanish_series' => l10n.collectionSpanishSeries,
    'latin_american_series' => l10n.collectionLatinAmericanSeries,
    'k_dramas' => l10n.collectionKDramas,
    'british_series' => l10n.collectionBritishSeries,
    'spanish_cinema' => l10n.collectionSpanishCinema,
    'korean_cinema' => l10n.collectionKoreanCinema,
    'bollywood' => l10n.collectionBollywood,
    'soaps' => l10n.collectionSoaps,
    'anime' => l10n.collectionAnime,
    'reality_shows' => l10n.collectionRealityShows,
    'kids' => l10n.collectionKids,
    _ => throw ArgumentError('Unknown collection id: $id'),
  };
}
