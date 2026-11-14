import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:movies/l10n/app_localizations_en.dart';
import 'package:movies/l10n/app_localizations_es.dart';
import 'package:movies/l10n/library_date_localization.dart';

final _now = DateTime(2026, 11, 14, 15);

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('es');
  });

  final en = AppLocalizationsEn();
  final es = AppLocalizationsEs();

  test('added: today, yesterday, days, weeks, then the full date', () {
    String at(int daysAgo, AppLocalizationsEn l) =>
        l.addedLabel(DateTime(2026, 11, 14 - daysAgo, 23), now: _now);
    expect(at(0, en), 'Added today');
    expect(at(1, en), 'Added yesterday');
    expect(at(3, en), 'Added 3 days ago');
    expect(at(7, en), 'Added 1 week ago');
    expect(at(14, en), 'Added 2 weeks ago');
    expect(at(34, en), 'Added 4 weeks ago');
    expect(en.addedLabel(DateTime(2026, 3, 5), now: _now), 'Added 5 Mar, 2026');
  });

  test('the Spanish equivalents', () {
    expect(es.addedLabel(_now, now: _now), 'Añadida hoy');
    expect(es.addedLabel(DateTime(2026, 11, 13), now: _now), 'Añadida ayer');
    expect(es.addedLabel(DateTime(2026, 11, 11), now: _now), 'Hace 3 días');
    expect(es.addedLabel(DateTime(2026, 11, 7), now: _now), 'Hace 1 semana');
    expect(es.addedLabel(DateTime(2026, 10, 31), now: _now), 'Hace 2 semanas');
    expect(
      es.addedLabel(DateTime(2026, 3, 5), now: _now),
      'Añadida 5 mar, 2026',
    );
  });
}
