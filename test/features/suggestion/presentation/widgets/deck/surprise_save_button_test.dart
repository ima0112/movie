import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/features/suggestion/presentation/cubit/surprise_cubit.dart';
import 'package:movies/features/suggestion/presentation/cubit/surprise_state.dart';
import 'package:movies/features/suggestion/presentation/widgets/deck/surprise_save_button.dart';
import 'package:movies/l10n/app_localizations.dart';

import '../../../surprise_test_data.dart';

class _FakeCubit extends Cubit<SurpriseState> implements SurpriseCubit {
  _FakeCubit(super.initial);

  final List<MediaKey> toggled = [];

  @override
  Future<void> toggleSaved(MediaKey key) async => toggled.add(key);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _key = MediaKey(type: MediaType.movie, tmdbId: 0);

SurpriseResult _deck({Set<MediaKey> saved = const {}}) => SurpriseResult(
  suggestions: batchOf(2).suggestions,
  index: 0,
  relaxations: const [],
  source: SuggestionSource.quiz,
  savedKeys: saved,
);

Future<_FakeCubit> _pump(WidgetTester tester, SurpriseResult state) async {
  final cubit = _FakeCubit(state);
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: BlocProvider<SurpriseCubit>.value(
          value: cubit,
          child: const Center(child: SurpriseSaveButton(mediaKey: _key)),
        ),
      ),
    ),
  );
  return cubit;
}

void main() {
  testWidgets('not saved: an outline bookmark; tapping asks to toggle it', (
    tester,
  ) async {
    final cubit = await _pump(tester, _deck());

    expect(find.byIcon(AppIcons.watchLater), findsOneWidget);
    expect(find.byIcon(AppIcons.watchLaterFill), findsNothing);

    await tester.tap(find.byType(SurpriseSaveButton));
    expect(cubit.toggled, [_key]);
  });

  testWidgets('saved: a solid amber bookmark, labelled for removal', (
    tester,
  ) async {
    await _pump(tester, _deck(saved: {_key}));

    expect(find.byIcon(AppIcons.watchLaterFill), findsOneWidget);
    expect(find.bySemanticsLabel('Remove from Watch later'), findsOneWidget);
  });
}
