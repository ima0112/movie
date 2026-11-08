import 'dart:convert';

import '../../../core/domain/entities/user_media_entry.dart';

/// "Export My List" (F11/C6) — My List as a readable JSON array, one
/// object per entry: title, type, id, favorite, watchLater, rating,
/// watchedAt. Pure — no file/share I/O here, so the shape itself is
/// unit-testable without a device; `settings_data_section.dart` is what
/// actually writes this to a file and hands it to the system share
/// sheet.
String libraryExportJson(List<UserMediaEntry> entries) {
  final data = entries.map(_toJson).toList();
  return const JsonEncoder.withIndent('  ').convert(data);
}

Map<String, dynamic> _toJson(UserMediaEntry entry) => {
  'title': entry.title,
  'type': entry.key.type.name,
  'id': entry.key.tmdbId,
  'favorite': entry.isFavorite,
  'watchLater': entry.isWatchLater,
  'rating': entry.rating,
  'watchedAt': entry.watchedAt?.toIso8601String(),
};
