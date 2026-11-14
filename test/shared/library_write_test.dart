import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/domain/entities/user_media_entry.dart';
import 'package:movies/core/theme/app_theme.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/l10n/app_localizations_en.dart';
import 'package:movies/l10n/app_localizations_es.dart';
import 'package:movies/l10n/library_feedback_localization.dart';
import 'package:movies/shared/library_write.dart';

const _key = MediaKey(type: MediaType.movie, tmdbId: 1);
const _dune = UserMediaEntry(key: _key, title: 'Dune');

class _FailingRepository extends InMemoryUserLibraryRepository {
  @override
  Future<Result<void>> upsert(UserMediaEntry entry) async =>
      Failure(FailureReason.storage);
}

Future<void> _run(
  WidgetTester tester,
  Future<void> Function(BuildContext) action, {
  Locale? locale,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => action(context),
            child: const Text('go'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('go'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a saved toggle says so, and Undo puts the old entry back', (
    tester,
  ) async {
    final repo = InMemoryUserLibraryRepository();
    final next = _dune.copyWith(isFavorite: true);
    await _run(
      tester,
      (c) => saveEntry(
        c,
        repo,
        next,
        message: AppLocalizationsEn().toggleMessage(null, next),
      ),
    );

    expect(find.text('Dune added to Favorites'), findsOneWidget);
    expect(await repo.watchEntry(_key).first, isNotNull);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    // The title wasn't in My List before: Undo deletes it.
    expect(await repo.watchEntry(_key).first, isNull);
  });

  testWidgets('Undo restores what was stored before', (tester) async {
    final repo = InMemoryUserLibraryRepository();
    await repo.upsert(_dune.copyWith(isWatchLater: true));
    final before = (await repo.watchEntry(_key).first)!;
    final next = before.copyWith(isWatchLater: false);
    await _run(
      tester,
      (c) => saveEntry(
        c,
        repo,
        next,
        previous: before,
        message: AppLocalizationsEn().toggleMessage(before, next),
      ),
    );
    expect(find.text('Dune removed from Watch later'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect((await repo.watchEntry(_key).first)!.isWatchLater, isTrue);
  });

  testWidgets('a failed write shows the storage failure, not the success '
      'message', (tester) async {
    await _run(
      tester,
      (c) => saveEntry(
        c,
        _FailingRepository(),
        _dune.copyWith(isFavorite: true),
        message: 'Dune added to Favorites',
      ),
    );

    expect(
      find.text('Something went wrong saving that on your device.'),
      findsOneWidget,
    );
    expect(find.text('Dune added to Favorites'), findsNothing);
    expect(find.text('Undo'), findsNothing);
  });

  group('messages', () {
    final en = AppLocalizationsEn();
    test('toggle: favorite and watch later, on and off; null when nothing '
        'flipped', () {
      final fav = _dune.copyWith(isFavorite: true);
      expect(en.toggleMessage(null, fav), 'Dune added to Favorites');
      expect(
        en.toggleMessage(fav, fav.copyWith(isFavorite: false)),
        'Dune removed from Favorites',
      );
      expect(
        en.toggleMessage(fav, fav.copyWith(isWatchLater: true)),
        'Dune added to Watch later',
      );
      expect(en.toggleMessage(fav, fav), isNull);
    });

    test('marked watched: plain, with the Watch later note, none when only '
        'editing', () {
      expect(
        en.markedWatchedMessage(null, _dune.markWatched()),
        'Dune marked as watched',
      );
      final later = _dune.copyWith(isWatchLater: true);
      expect(
        en.markedWatchedMessage(later, later.markWatched()),
        'Dune marked as watched · Removed from Watch later',
      );
      final watched = _dune.markWatched();
      expect(en.markedWatchedMessage(watched, watched.markWatched()), isNull);
    });

    test('Spanish', () {
      final es = AppLocalizationsEs();
      expect(
        es.toggleMessage(null, _dune.copyWith(isWatchLater: true)),
        'Dune añadida a Ver después',
      );
      final later = _dune.copyWith(isWatchLater: true);
      expect(
        es.markedWatchedMessage(later, later.markWatched()),
        'Dune marcada como vista · Quitada de Ver después',
      );
    });
  });
}
