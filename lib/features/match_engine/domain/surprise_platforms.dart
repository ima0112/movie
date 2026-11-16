import '../../../core/domain/entities/streaming_service.dart';
import '../../../core/domain/entities/watch_providers.dart';
import 'participant_answers.dart';

/// Which streaming services a Surprise-me card lists — the ones the search
/// itself counts as "available": included in a plan, plus rent and buy when the
/// user asked for them; and, when the user picked specific platforms, only
/// those (a title on Netflix and Max shows just Netflix if only Netflix was
/// picked). With "All platforms" every such service of the region is listed.
///
/// Pure function of what TMDB said about the title and the user's answers.
List<StreamingService> platformsFor(
  WatchProviders providers,
  ParticipantAnswers answers,
) {
  final names = <String>[
    ...providers.flatrate,
    if (answers.includeRentBuy) ...providers.rent,
    if (answers.includeRentBuy) ...providers.buy,
  ];
  final seen = <String>{};
  final result = <StreamingService>[];
  for (final name in names) {
    if (!seen.add(name)) continue;
    final id = providers.ids[name];
    if (answers.platformIds.isNotEmpty &&
        (id == null || !answers.platformIds.contains(id))) {
      continue;
    }
    result.add(
      StreamingService(id: id ?? 0, name: name, logoUrl: providers.logos[name]),
    );
  }
  return result;
}
