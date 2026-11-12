import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/trailer_item.dart';
import 'package:movies/core/domain/entities/video.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/trailer_carousel.dart';

TrailerItem _trailer(int id, {String? backdrop}) => TrailerItem(
  item: Movie(
    id: id,
    title: 'Movie $id',
    posterUrl: null,
    backdropUrl: backdrop,
    genres: const [],
    releaseDate: DateTime(2026),
    voteAverage: 7,
  ),
  video: Video(key: 'key$id', site: 'YouTube', type: 'Trailer', name: 't'),
);

Widget _host(List<TrailerItem> items, void Function(TrailerItem) onTap) =>
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: ListView(
          children: [TrailerCarousel(trailers: items, onTrailerTap: onTap)],
        ),
      ),
    );

void main() {
  testWidgets('each card shows the title and a play button; tapping reports '
      'that trailer', (tester) async {
    TrailerItem? tapped;
    await tester.pumpWidget(
      _host([_trailer(1), _trailer(2)], (t) => tapped = t),
    );

    expect(find.text('Movie 1'), findsOneWidget);
    expect(find.byIcon(AppIcons.play), findsWidgets);

    await tester.tap(find.text('Movie 1'));
    expect(tapped?.video.key, 'key1');
  });

  test('without a backdrop the still is the YouTube thumbnail', () {
    expect(
      TrailerCarousel.thumbnailUrl('abc'),
      'https://img.youtube.com/vi/abc/hqdefault.jpg',
    );
  });
}
