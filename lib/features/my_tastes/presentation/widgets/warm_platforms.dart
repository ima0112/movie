import 'package:flutter/widgets.dart';

import '../../../../app/di.dart';
import '../../../../core/domain/entities/result.dart';
import '../../../../core/domain/entities/streaming_service.dart';
import '../../../../core/domain/entities/taste_profile.dart';
import '../../../../core/domain/repositories/media_repository.dart';

/// Asks for the region's streaming services as C5 opens and decodes the logos
/// of the user's saved ones, so "My platforms" — the last section, below the
/// fold — has everything the moment it scrolls into view. Best effort: a
/// failure or a missing repository just leaves the section to load on its own.
Future<void> warmPlatforms(BuildContext context, TasteProfile? profile) async {
  if (!getIt.isRegistered<MediaRepository>()) return;
  final result = await getIt<MediaRepository>().streamingServices(all: true);
  if (result is! Success<List<StreamingService>>) return;
  final mine = profile?.platformIds ?? const <int>{};
  for (final service in result.value) {
    final url = service.logoUrl;
    if (!mine.contains(service.id) || url == null) continue;
    if (!context.mounted) return;
    try {
      await precacheImage(NetworkImage(url), context);
    } catch (_) {
      // A logo that fails to load shows the name's letter later; nothing to do.
    }
  }
}
