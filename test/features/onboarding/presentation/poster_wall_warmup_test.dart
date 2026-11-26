import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/di.dart';
import 'package:movies/core/data/local/in_memory_onboarding_repository.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/domain/repositories/media_repository.dart';
import 'package:movies/core/domain/repositories/onboarding_repository.dart';
import 'package:movies/shared/widgets/app_network_image.dart';
import 'package:movies/features/onboarding/presentation/poster_wall_warmup.dart';
import 'package:movies/features/onboarding/presentation/widgets/poster_wall.dart';
import 'package:movies/features/onboarding/presentation/widgets/poster_wall_tiles.dart';

const _screen = Size(390, 844);

class _Repo implements MediaRepository {
  _Repo(this.items);
  final List<MediaItem> items;
  int asked = 0;

  @override
  Future<Result<List<MediaItem>>> getPosterWallItems() async {
    asked++;
    return Success(items);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

List<String> _urls(int n) =>
    List.generate(n, (i) => 'https://image.tmdb.org/t/p/w342/p$i.jpg');

Widget _wall(List<String> urls) => MaterialApp(
  home: MediaQuery(
    data: const MediaQueryData(size: _screen, disableAnimations: true),
    child: PosterWall(posterUrls: urls),
  ),
);

void main() {
  group('which posters show first', () {
    test('a handful per column, distinct, never more than the cap', () {
      final warm = PosterWallWarmup.visiblePosterUrls(_urls(60), _screen);

      expect(warm, isNotEmpty);
      expect(warm.length, lessThanOrEqualTo(PosterWallWarmup.maxPosters));
      expect(warm.toSet(), hasLength(warm.length));
    });

    test('no posters, nothing to warm', () {
      expect(PosterWallWarmup.visiblePosterUrls(const [], _screen), isEmpty);
    });

    testWidgets('every poster the wall really paints in its first frame is '
        'among them', (tester) async {
      await tester.binding.setSurfaceSize(_screen);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final urls = _urls(60);
      await tester.pumpWidget(_wall(urls));

      final warm = PosterWallWarmup.visiblePosterUrls(urls, _screen).toSet();
      final screenRect = Offset.zero & _screen;
      final shown = <String>{};
      for (final element in tester.elementList(find.byType(AppNetworkImage))) {
        final widget = element.widget as AppNetworkImage;
        final box = element.findRenderObject()! as RenderBox;
        final rect = box.localToGlobal(Offset.zero) & box.size;
        // Painted at least half inside the screen.
        final visible = rect.intersect(screenRect);
        if (visible.width > 0 &&
            visible.height > 0 &&
            visible.height >= rect.height / 2) {
          shown.add(widget.url!);
        }
      }

      expect(shown, isNotEmpty);
      expect(
        warm.containsAll(shown),
        isTrue,
        reason: '${shown.difference(warm)}',
      );
    });

    testWidgets('a tile is drawn at the width the warm-up warms it at', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(_screen);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_wall(_urls(60)));

      final tile = tester.firstElement(find.byType(AppNetworkImage));
      final box = tile.findRenderObject()! as RenderBox;

      expect(
        box.size.width,
        closeTo(PosterWallWarmup.tileWidth(_screen.width), 1e-6),
      );
      expect(PosterWallTiles.fade, lessThan(AppNetworkImage.fadeDuration));
    });
  });

  group('the splash step', () {
    late _Repo repo;

    Future<void> run(WidgetTester tester) async {
      late BuildContext context;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (c) {
              context = c;
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.runAsync(() => PosterWallWarmup.run(context));
    }

    void register({required bool completed}) {
      repo = _Repo([
        for (final u in _urls(30))
          Movie(
            id: u.hashCode,
            title: 't',
            posterUrl: u,
            genres: const [],
            releaseDate: DateTime(2020),
            voteAverage: 7,
          ),
      ]);
      if (getIt.isRegistered<MediaRepository>()) {
        getIt.unregister<MediaRepository>();
      }
      if (getIt.isRegistered<OnboardingRepository>()) {
        getIt.unregister<OnboardingRepository>();
      }
      getIt.registerSingleton<MediaRepository>(repo);
      getIt.registerSingleton<OnboardingRepository>(
        InMemoryOnboardingRepository(isCompleted: completed),
      );
      PosterWallWarmup.reset();
    }

    tearDown(() {
      PosterWallWarmup.reset();
      getIt.reset();
    });

    testWidgets('onboarding to do: asks for the list once and hands it over '
        'to the flow (taken once)', (tester) async {
      register(completed: false);

      await run(tester);

      expect(repo.asked, 1);
      expect(PosterWallWarmup.takePosters(), isNotNull);
      expect(PosterWallWarmup.takePosters(), isNull);
    });

    testWidgets('onboarding done: it does nothing', (tester) async {
      register(completed: true);

      await run(tester);

      expect(repo.asked, 0);
      expect(PosterWallWarmup.takePosters(), isNull);
    });
  });
}
