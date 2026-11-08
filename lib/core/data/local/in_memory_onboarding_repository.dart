import '../../domain/entities/result.dart';
import '../../domain/repositories/onboarding_repository.dart';

/// In-memory stand-in for [OnboardingRepository] — same role as
/// `InMemoryUserLibraryRepository`: `DriftOnboardingRepository` needs a
/// native sqlite file via `path_provider`, which has no platform
/// channel in `flutter test`'s host environment, so widget tests that
/// pump the real app through `appRouter` swap this in instead. Not
/// `@LazySingleton`: only one implementation may be registered
/// `as: OnboardingRepository`.
///
/// [isCompleted] starts `true` by default — most widget tests that
/// pump the full app are testing *something past onboarding*
/// (Discover, a detail screen...), not the gate itself; a test for the
/// gate's own redirect passes `isCompleted: false` explicitly. [load]
/// is a no-op: there's nothing to load, the constructor already set
/// the value a test asked for.
class InMemoryOnboardingRepository implements OnboardingRepository {
  InMemoryOnboardingRepository({this.isCompleted = true});

  @override
  bool isCompleted;

  @override
  Future<void> load() async {}

  @override
  Future<Result<void>> markCompleted() async {
    isCompleted = true;
    return const Success(null);
  }
}
