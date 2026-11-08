import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_item.dart';
import 'package:movies/core/domain/entities/person.dart';
import 'package:movies/features/person_detail/presentation/widgets/person_filmography_section.dart';

Movie _movie(int id, String title, {DateTime? releaseDate}) => Movie(
  id: id,
  title: title,
  posterUrl: null,
  genres: const [],
  releaseDate: releaseDate,
  voteAverage: 7,
);

void main() {
  group('PersonFilmographySection', () {
    testWidgets('no "As director" chip for cast-only credits', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PersonFilmographySection(
              credits: [
                MediaCredit(
                  item: _movie(1, 'A', releaseDate: DateTime(2020, 1, 1)),
                  character: 'Lead',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('As director'), findsNothing);
    });

    testWidgets('"As director" chip appears once both cast and crew '
        'credits exist', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PersonFilmographySection(
              credits: [
                MediaCredit(
                  item: _movie(1, 'A', releaseDate: DateTime(2020, 1, 1)),
                  character: 'Lead',
                ),
                MediaCredit(
                  item: _movie(2, 'B', releaseDate: DateTime(2021, 1, 1)),
                  job: 'Director',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('As director'), findsOneWidget);
    });

    testWidgets('selecting "As director" narrows the list to directing '
        'credits', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PersonFilmographySection(
              credits: [
                MediaCredit(
                  item: _movie(
                    1,
                    'Acted In',
                    releaseDate: DateTime(2020, 1, 1),
                  ),
                  character: 'Lead',
                ),
                MediaCredit(
                  item: _movie(
                    2,
                    'Directed',
                    releaseDate: DateTime(2021, 1, 1),
                  ),
                  job: 'Director',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Acted In'), findsOneWidget);
      expect(find.text('Directed'), findsOneWidget);

      await tester.tap(find.text('As director'));
      await tester.pump();

      expect(find.text('Acted In'), findsNothing);
      expect(find.text('Directed'), findsOneWidget);
    });

    testWidgets('groups rows under a year header', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PersonFilmographySection(
              credits: [
                MediaCredit(
                  item: _movie(1, 'A', releaseDate: DateTime(2020, 1, 1)),
                  character: 'Lead',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('2020'), findsOneWidget);
    });
  });
}
