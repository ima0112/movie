import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/cubits/user_profile_cubit.dart';
import 'package:movies/core/data/local/in_memory_user_library_repository.dart';
import 'package:movies/core/data/local/in_memory_user_profile_repository.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/user_media_entry.dart';
import 'package:movies/core/domain/entities/user_profile.dart';
import 'package:movies/core/domain/repositories/user_library_repository.dart';
import 'package:movies/features/you/presentation/cubit/you_stats_cubit.dart';
import 'package:movies/features/you/presentation/widgets/you_header.dart';
import 'package:movies/features/you/presentation/widgets/you_viewer_label.dart';
import 'package:movies/l10n/app_localizations.dart';

Future<void> _pump(
  WidgetTester tester,
  UserLibraryRepository repo, {
  Locale? locale,
}) async {
  final profiles = InMemoryUserProfileRepository();
  await profiles.save(
    const UserProfile(displayName: 'Daniel', initialColor: 0xFFF2B441),
  );
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => UserProfileCubit(profiles)),
          BlocProvider(create: (_) => YouStatsCubit(repo)),
        ],
        child: Scaffold(
          body: YouHeader(onEditProfile: () {}, onOpenSettings: () {}),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<InMemoryUserLibraryRepository> _repo(
  int count, {
  List<Genre> genres = const [],
}) async {
  final repo = InMemoryUserLibraryRepository();
  for (var i = 1; i <= count; i++) {
    await repo.upsert(
      UserMediaEntry(
        key: MediaKey(type: MediaType.movie, tmdbId: i),
        title: 'T$i',
        watchedAt: DateTime(2026, 11, 1),
        genres: genres,
      ),
    );
  }
  return repo;
}

void main() {
  testWidgets('nothing watched: the name alone, no label', (tester) async {
    await _pump(tester, await _repo(0));

    expect(find.text('Hi, Daniel'), findsOneWidget);
    expect(find.byType(YouViewerLabel), findsOneWidget);
    expect(find.text('Just getting started'), findsNothing);
  });

  testWidgets('a few titles: newcomer, under the greeting', (tester) async {
    await _pump(tester, await _repo(2));

    expect(find.text('Just getting started'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Just getting started')).dy,
      greaterThan(tester.getTopLeft(find.text('Hi, Daniel')).dy),
    );
  });

  testWidgets('a genre that stands out: "Fan of …" in the user\'s language', (
    tester,
  ) async {
    final repo = await _repo(6, genres: const [Genre(id: 'sci-fi')]);
    await _pump(tester, repo, locale: const Locale('es'));

    expect(find.text('Fan de Ciencia ficción'), findsOneWidget);
  });
}
