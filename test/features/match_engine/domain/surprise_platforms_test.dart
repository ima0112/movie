import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/watch_providers.dart';
import 'package:movies/features/match_engine/domain/participant_answers.dart';
import 'package:movies/features/match_engine/domain/surprise_platforms.dart';

const _providers = WatchProviders(
  flatrate: ['Netflix', 'Max'],
  rent: ['Apple TV', 'Netflix'],
  buy: ['Google Play'],
  link: null,
  logos: {
    'Netflix': 'n.png',
    'Max': 'm.png',
    'Apple TV': 'a.png',
    'Google Play': 'g.png',
  },
  ids: {'Netflix': 8, 'Max': 1899, 'Apple TV': 2, 'Google Play': 3},
);

ParticipantAnswers _answers({
  Set<int> platforms = const {},
  bool rentBuy = false,
}) => ParticipantAnswers(
  participantId: 'me',
  yearFrom: 1950,
  platformIds: platforms,
  includeRentBuy: rentBuy,
);

List<String> _names(WatchProviders p, ParticipantAnswers a) => [
  for (final s in platformsFor(p, a)) s.name,
];

void main() {
  test('All platforms, subscription only: every service in a plan, with its '
      'id and logo', () {
    final list = platformsFor(_providers, _answers());

    expect([for (final s in list) s.name], ['Netflix', 'Max']);
    expect([for (final s in list) s.id], [8, 1899]);
    expect([for (final s in list) s.logoUrl], ['n.png', 'm.png']);
  });

  test('with rent and buy asked, those count too — without repeating a '
      'service that is in both lists', () {
    expect(_names(_providers, _answers(rentBuy: true)), [
      'Netflix',
      'Max',
      'Apple TV',
      'Google Play',
    ]);
  });

  test('picked platforms narrow the list to those services only', () {
    expect(_names(_providers, _answers(platforms: {8})), ['Netflix']);
    expect(_names(_providers, _answers(platforms: {1899, 8})), [
      'Netflix',
      'Max',
    ]);
  });

  test('a picked platform the title is only rentable on shows up only when '
      'rent and buy is asked', () {
    expect(_names(_providers, _answers(platforms: {2})), isEmpty);
    expect(_names(_providers, _answers(platforms: {2}, rentBuy: true)), [
      'Apple TV',
    ]);
  });

  test('a service with no id cannot match a picked platform, but is listed '
      'under All platforms', () {
    const noIds = WatchProviders(
      flatrate: ['Mystery'],
      rent: [],
      buy: [],
      link: null,
    );

    expect(_names(noIds, _answers(platforms: {8})), isEmpty);
    expect(_names(noIds, _answers()), ['Mystery']);
  });

  test('no providers at all: nothing', () {
    expect(platformsFor(WatchProviders.empty, _answers()), isEmpty);
  });
}
