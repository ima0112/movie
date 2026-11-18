import '../../../core/domain/entities/result.dart';
import 'surprise_batch.dart';
import 'surprise_request.dart';

/// The Surprise-me engine (`docs/DECISIONS.md` §5, "Surprise me engine"):
/// from the questionnaire's answers, five different suggestions from TMDB,
/// no AI. Hard filters (vetoes, platforms, years, runtime, status) are never
/// broken; vibes and tastes only order; a batch never repeats what its
/// session — or, on a redone questionnaire, the recent history — already
/// showed.
///
/// Pure domain contract — the implementation reaches TMDB only through
/// `MediaRepository`. Separate from `MatchEngine`, which resolves one answer
/// for a group (the Matcher, v1.1).
abstract interface class SurpriseEngine {
  /// A new batch for [request]. A [Failure] only when TMDB can't be reached;
  /// "nothing found" is a [SurpriseBatch] that [SurpriseBatch.isEmpty].
  Future<Result<SurpriseBatch>> resolve(SurpriseRequest request);
}
