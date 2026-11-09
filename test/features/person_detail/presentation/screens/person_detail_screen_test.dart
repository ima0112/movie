import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/di.dart';
import 'package:movies/app/environments.dart';
import 'package:movies/core/domain/entities/person.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/domain/repositories/person_repository.dart';
import 'package:movies/core/theme/app_spacing.dart';
import 'package:movies/features/person_detail/presentation/screens/person_detail_screen.dart';
import 'package:movies/features/person_detail/presentation/widgets/person_biography_section.dart';
import 'package:movies/features/person_detail/presentation/widgets/person_detail_header.dart';
import 'package:movies/features/person_detail/presentation/widgets/person_filmography_link_card.dart';
import 'package:movies/features/person_detail/presentation/widgets/person_known_for_section.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/media_detail/media_detail_compact_bar.dart';
import 'package:movies/shared/widgets/profile_image.dart';
import 'package:movies/shared/widgets/scrim_back_button.dart';

/// D3 on the fake repository's Denis Villeneuve (id 1004): checks the
/// alignment and spacing the "Persona" design asks for, on a phone.
void main() {
  setUpAll(() => configureDependencies(fake.name));

  Future<void> open(WidgetTester tester, {Size? size, double scale = 1}) async {
    tester.view.physicalSize = size ?? const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: const PersonDetailScreen(personId: 1004),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('photo, name and details are centered; content and the back '
      'button share the screen margin', (tester) async {
    await open(tester);

    const width = 390.0;
    expect(tester.getCenter(find.byType(ProfileImage)).dx, width / 2);
    expect(tester.getCenter(find.text('Denis Villeneuve').first).dx, width / 2);

    final backCircle = tester.getRect(
      find.descendant(
        of: find.byType(ScrimBackButton),
        matching: find.byType(Container),
      ),
    );
    expect(backCircle.left, AppSpacing.screenMargin);

    // Every section's content starts at the screen margin.
    expect(
      tester.getTopLeft(find.text('Conocido por')).dx,
      AppSpacing.screenMargin,
    );
    expect(
      tester.getTopLeft(find.text('Filmografía')).dx,
      AppSpacing.screenMargin,
    );
    final card = tester.getRect(
      find.descendant(
        of: find.byType(PersonFilmographyLinkCard),
        matching: find.byType(Container),
      ),
    );
    expect(card.left, AppSpacing.screenMargin);
    expect(card.right, width - AppSpacing.screenMargin);
  });

  testWidgets('sections are one sectionGap apart, header included', (
    tester,
  ) async {
    await open(tester);

    double top(Type t) => tester.getTopLeft(find.byType(t)).dy;
    double bottom(Type t) => tester.getBottomLeft(find.byType(t)).dy;
    // Each section box starts where the previous one ends (it owns the gap
    // above its own content, none below).
    expect(top(PersonBiographySection), bottom(PersonDetailHeader));
    expect(top(PersonKnownForSection), bottom(PersonBiographySection));
    expect(top(PersonFilmographyLinkCard), bottom(PersonKnownForSection));
    // And the bio's first line sits exactly one sectionGap under the header.
    expect(
      tester.getTopLeft(find.text('Biografía en inglés')).dy -
          bottom(PersonDetailHeader),
      AppSpacing.sectionGap,
    );
  });

  testWidgets('Leer más expands the biography and becomes Leer menos, which '
      'folds it back', (tester) async {
    await open(tester);

    double bioHeight() =>
        tester.getSize(find.byType(PersonBiographySection)).height;
    final folded = bioHeight();

    expect(find.text('Leer más'), findsOneWidget);
    await tester.tap(find.text('Leer más'));
    await tester.pumpAndSettle();
    expect(find.text('Leer menos'), findsOneWidget);
    expect(find.text('Leer más'), findsNothing);
    expect(bioHeight(), greaterThan(folded));

    await tester.tap(find.text('Leer menos'));
    await tester.pumpAndSettle();
    expect(find.text('Leer más'), findsOneWidget);
    expect(bioHeight(), folded);
  });

  testWidgets('survives a small device at 200% text scale', (tester) async {
    await open(tester, size: const Size(320, 568), scale: 2);
    expect(tester.takeException(), isNull);
    expect(find.text('Denis Villeneuve'), findsWidgets);
  });

  testWidgets('the compact bar stays once shown, even far down a very long '
      'biography (the header is no longer built)', (tester) async {
    final original = getIt<PersonRepository>();
    addTearDown(() {
      getIt.unregister<PersonRepository>();
      getIt.registerSingleton<PersonRepository>(original);
    });
    getIt.unregister<PersonRepository>();
    getIt.registerSingleton<PersonRepository>(_LongBioRepository(original));

    await open(tester, size: const Size(390, 700));
    // Expand the bio so there is a lot to scroll through.
    await tester.tap(find.text('Leer más'));
    await tester.pumpAndSettle();
    expect(find.byType(MediaDetailCompactBar), findsNothing);

    final listFinder = find.byType(ListView);
    for (final dy in [-400.0, -1500.0, -3000.0, -3000.0]) {
      await tester.drag(listFinder, Offset(0, dy));
      await tester.pumpAndSettle();
      expect(
        find.byType(MediaDetailCompactBar),
        findsOneWidget,
        reason: 'after dragging $dy',
      );
    }

    // Back at the very top the bar turns into the transparent header again.
    await tester.drag(listFinder, const Offset(0, 20000));
    await tester.pumpAndSettle();
    expect(find.byType(MediaDetailCompactBar), findsNothing);
  });
}

class _LongBioRepository implements PersonRepository {
  _LongBioRepository(this._inner);

  final PersonRepository _inner;

  @override
  Future<Result<PersonDetail>> detail(int personId) async {
    final result = await _inner.detail(personId);
    if (result is! Success<PersonDetail>) return result;
    final d = result.value;
    return Success(
      PersonDetail(
        person: d.person,
        biography: List.filled(
          120,
          'A very long biography paragraph.',
        ).join('\n\n'),
        biographyIsEnglishFallback: false,
        birthday: d.birthday,
        deathday: d.deathday,
        placeOfBirth: d.placeOfBirth,
        credits: d.credits,
      ),
    );
  }
}
