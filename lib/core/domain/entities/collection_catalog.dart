import 'dart:convert';

import 'collection.dart';
import 'media_type.dart';

/// The collections, parsed from `assets/collections.json` (read by
/// `core/data/assets/collection_catalog_loader.dart`; this class is pure).
///
/// The list is data, not code: a new collection is a new row in the JSON.
class CollectionCatalog {
  const CollectionCatalog(this._collections);

  final List<Collection> _collections;

  factory CollectionCatalog.fromJsonString(String source) =>
      CollectionCatalog.fromJson(jsonDecode(source) as Map<String, dynamic>);

  factory CollectionCatalog.fromJson(Map<String, dynamic> json) =>
      CollectionCatalog([
        for (final c in json['collections'] as List)
          Collection.fromJson(c as Map<String, dynamic>),
      ]);

  List<Collection> all() => List.unmodifiable(_collections);

  /// `null` for an unknown id (a stale stored one is dropped, not invented).
  Collection? byId(String id) {
    for (final c in _collections) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// The collections that exist for [type], in the file's order.
  List<Collection> availableFor(MediaType type) => [
    for (final c in _collections)
      if (c.isAvailableFor(type)) c,
  ];

  /// The ones of [group] that exist for [type].
  List<Collection> inGroup(CollectionGroup group, MediaType type) => [
    for (final c in availableFor(type))
      if (c.group == group) c,
  ];
}
