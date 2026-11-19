import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/collection_catalog.dart';
import 'package:movies/l10n/app_localizations_en.dart';
import 'package:movies/l10n/app_localizations_es.dart';
import 'package:movies/l10n/collection_localization.dart';

void main() {
  final catalog = CollectionCatalog.fromJsonString(
    File('assets/collections.json').readAsStringSync(),
  );

  test('every collection in assets/collections.json has a name in both '
      'languages (the mapper throws on an id it does not know)', () {
    final en = AppLocalizationsEn();
    final es = AppLocalizationsEs();
    for (final c in catalog.all()) {
      expect(c.localizedName(en), isNotEmpty, reason: c.id);
      expect(c.localizedName(es), isNotEmpty, reason: c.id);
    }
  });

  test('a few names', () {
    expect(
      catalog.byId('soaps')!.localizedName(AppLocalizationsEs()),
      'Novelas',
    );
    expect(
      catalog.byId('kids')!.localizedName(AppLocalizationsEn()),
      'For kids',
    );
  });
}
