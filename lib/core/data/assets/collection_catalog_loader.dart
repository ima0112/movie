import 'package:flutter/services.dart' show rootBundle;

import '../../domain/entities/collection_catalog.dart';

/// Reads and parses `assets/collections.json` once per process — the bundled
/// file never changes at runtime, so every screen shares one resolved future.
Future<CollectionCatalog>? _cached;

Future<CollectionCatalog> loadCollectionCatalog() => _cached ??= rootBundle
    .loadString('assets/collections.json')
    .then(CollectionCatalog.fromJsonString);
