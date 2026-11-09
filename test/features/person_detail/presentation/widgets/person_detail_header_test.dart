import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/person.dart';
import 'package:movies/features/person_detail/presentation/widgets/person_detail_header.dart';

const _person = Person(
  id: 1,
  name: 'Timothée Chalamet',
  profilePath: null,
  knownForDepartment: 'Acting',
);

void main() {
  group('PersonDetailHeader', () {
    testWidgets('shows the name and department', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PersonDetailHeader(
              person: _person,
              ageLabel: null,
              placeOfBirth: null,
            ),
          ),
        ),
      );

      expect(find.text('Timothée Chalamet'), findsOneWidget);
      expect(find.text('Acting'), findsOneWidget);
    });

    testWidgets(
      'joins the department, age label and place of birth with " · "',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PersonDetailHeader(
                person: _person,
                ageLabel: '28 years old',
                placeOfBirth: 'New York City, New York, USA',
              ),
            ),
          ),
        );

        expect(
          find.text('Acting · 28 years old · New York City, New York, USA'),
          findsOneWidget,
        );
      },
    );

    testWidgets('shows just the age label when place of birth is '
        'unknown', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PersonDetailHeader(
              person: _person,
              ageLabel: '28 years old',
              placeOfBirth: null,
            ),
          ),
        ),
      );

      expect(find.text('Acting · 28 years old'), findsOneWidget);
    });

    testWidgets('survives a small device at 200% text scale with a long '
        'details line', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 568),
              textScaler: TextScaler.linear(2),
            ),
            child: const Scaffold(
              body: SingleChildScrollView(
                child: PersonDetailHeader(
                  person: _person,
                  ageLabel: '28 years old',
                  placeOfBirth: 'New York City, New York, United States',
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
