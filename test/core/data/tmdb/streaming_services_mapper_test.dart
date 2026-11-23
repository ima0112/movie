import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/data/tmdb/tmdb_image_urls.dart';
import 'package:movies/core/data/tmdb/tmdb_mappers.dart';

void main() {
  const config = TmdbImagesConfig(
    secureBaseUrl: 'https://image.tmdb.org/t/p/',
    posterSizes: ['w92', 'w500'],
    backdropSizes: ['w780'],
    profileSizes: ['w185'],
    stillSizes: ['w300'],
  );

  // 20 services whose *regional* ranking is 1..20 but whose global
  // `display_priority` runs the other way round, with Peacock 17th.
  final raw = [
    for (var i = 1; i <= 20; i++)
      {
        'provider_id': i,
        'provider_name': i == 17 ? 'Peacock Premium' : 'Service $i',
        'logo_path': null,
        'display_priority': 100 - i,
        'display_priorities': {'US': i},
      },
  ];

  test('ranks by the region\'s own priority and keeps what fits in the '
      'limit — Peacock is 17th in the US', () {
    final services = streamingServicesFromJson(
      raw,
      imagesConfig: config,
      limit: 30,
      regionCode: 'US',
    );

    expect(services, hasLength(20));
    expect(services.first.name, 'Service 1');
    expect(services[16].name, 'Peacock Premium');
  });

  test('a limit of 15 is what hid Peacock', () {
    final services = streamingServicesFromJson(
      raw,
      imagesConfig: config,
      limit: 15,
      regionCode: 'US',
    );

    expect(services.map((s) => s.name), isNot(contains('Peacock Premium')));
  });

  test('the user\'s own services lead the short list, even Peacock ranked '
      '17th; each group keeps the region\'s order', () {
    final services = streamingServicesFromJson(
      raw,
      imagesConfig: config,
      limit: 12,
      regionCode: 'US',
      preferredIds: {17, 3},
    );

    expect(services, hasLength(12));
    expect(services.take(2).map((s) => s.name), [
      'Service 3',
      'Peacock Premium',
    ]);
    expect(services[2].name, 'Service 1'); // then the best, in order
    expect(services.last.name, 'Service 11');
  });

  test('more of the user\'s services than the limit: the first of theirs, in '
      'the region\'s order', () {
    final services = streamingServicesFromJson(
      raw,
      imagesConfig: config,
      limit: 3,
      regionCode: 'US',
      preferredIds: {20, 19, 18, 17},
    );

    expect(services.map((s) => s.id), [17, 18, 19]);
  });

  test('no limit at all (the picker\'s search): every service of the region, '
      'still ranked', () {
    final services = streamingServicesFromJson(
      raw,
      imagesConfig: config,
      regionCode: 'US',
    );

    expect(services, hasLength(20));
    expect(services.first.name, 'Service 1');
    expect(services.last.name, 'Service 20');
  });

  test('without the region it falls back to the global display_priority', () {
    final services = streamingServicesFromJson(
      raw,
      imagesConfig: config,
      limit: 30,
    );

    expect(services.first.name, 'Service 20');
  });

  test('storefronts and re-sold bundles are not services to subscribe to', () {
    final services = streamingServicesFromJson(
      [
        for (final (i, name) in [
          'Netflix',
          'JustWatch TV Free',
          'Amazon Video',
          'Apple TV Store',
          'HBO Max Amazon Channel',
          'Disney Plus',
        ].indexed)
          {
            'provider_id': i,
            'provider_name': name,
            'logo_path': null,
            'display_priorities': {'US': i},
          },
      ],
      imagesConfig: config,
      limit: 8,
      regionCode: 'US',
    );

    expect(services.map((s) => s.name), ['Netflix', 'Disney Plus']);
  });
}
