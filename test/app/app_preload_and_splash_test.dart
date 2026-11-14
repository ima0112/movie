import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/app_preload.dart';
import 'package:movies/app/di.dart';
import 'package:movies/app/environments.dart';
import 'package:movies/app/splash_screen.dart';
import 'package:movies/core/data/local/in_memory_onboarding_repository.dart';
import 'package:movies/core/domain/repositories/onboarding_repository.dart';
import 'package:movies/core/domain/repositories/settings_repository.dart';
import 'package:movies/core/domain/entities/app_settings.dart';
import 'package:movies/core/domain/entities/result.dart';

class _CountingOnboarding extends InMemoryOnboardingRepository {
  int loads = 0;

  @override
  Future<void> load() async {
    loads++;
    return super.load();
  }
}

class _Settings implements SettingsRepository {
  _Settings({this.fails = false});

  final bool fails;
  int loads = 0;

  @override
  AppSettings get current =>
      const AppSettings(languageCode: 'en', regionCode: 'US');

  @override
  Future<void> load() async {
    loads++;
    if (fails) throw StateError('disk is on fire');
  }

  @override
  Stream<AppSettings> watch() => Stream.value(current);

  @override
  Future<Result<void>> save(AppSettings settings) async => const Success(null);
}

void main() {
  group('preloadApp', () {
    late _CountingOnboarding onboarding;

    setUp(() {
      configureDependencies(fake.name);
      onboarding = _CountingOnboarding();
      getIt.unregister<OnboardingRepository>();
      getIt.registerSingleton<OnboardingRepository>(onboarding);
    });
    tearDown(getIt.reset);

    test('loads onboarding and settings and fetches Home\'s first carousel, '
        'all at once', () async {
      final settings = _Settings();
      getIt.unregister<SettingsRepository>();
      getIt.registerSingleton<SettingsRepository>(settings);

      await preloadApp();

      expect(onboarding.loads, 1);
      expect(settings.loads, 1);
    });

    test('never throws: a failed head start is not a failed launch (the '
        'splash would otherwise wait forever)', () async {
      getIt.unregister<SettingsRepository>();
      getIt.registerSingleton<SettingsRepository>(_Settings(fails: true));

      await expectLater(preloadApp(), completes);
    });
  });

  group('SplashScreen', () {
    Future<void> pump(
      WidgetTester tester, {
      required Future<void> Function() preload,
      required VoidCallback onFinished,
    }) => tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(preload: preload, onFinished: onFinished),
      ),
    );

    testWidgets('with the preload already done it still plays its whole '
        'animation (~1.3 s), not a frame less', (tester) async {
      var finished = false;
      await pump(
        tester,
        preload: () => Future.value(),
        onFinished: () => finished = true,
      );

      await tester.pump(const Duration(milliseconds: 1200));
      expect(finished, isFalse);

      await tester.pump(const Duration(milliseconds: 150));
      expect(finished, isTrue);
      // The 1.5 s ceiling's own timer is still pending.
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('a slow preload never holds it past 1.5 s', (tester) async {
      var finished = false;
      final never = Completer<void>();
      await pump(
        tester,
        preload: () => never.future,
        onFinished: () => finished = true,
      );

      await tester.pump(const Duration(milliseconds: 1400));
      expect(finished, isFalse);
      await tester.pump(const Duration(milliseconds: 150));
      expect(finished, isTrue);
    });

    testWidgets('it asks for the preload once, when it mounts', (tester) async {
      var asked = 0;
      await pump(
        tester,
        preload: () {
          asked++;
          return Future.value();
        },
        onFinished: () {},
      );
      await tester.pump(const Duration(milliseconds: 1600));

      expect(asked, 1);
    });

    testWidgets('it starts on the page\'s dark color: the native splash is '
        'only that color, so nothing jumps', (tester) async {
      await pump(tester, preload: () => Future.value(), onFinished: () {});

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFF0B0B0D));
      await tester.pump(const Duration(milliseconds: 1600));
    });
  });
}
