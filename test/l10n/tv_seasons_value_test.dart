import 'package:flutter_test/flutter_test.dart';
import 'package:movies/l10n/app_localizations_en.dart';
import 'package:movies/l10n/app_localizations_es.dart';

void main() {
  test('the Seasons card value is "seasons · episodes word", pluralised', () {
    final en = AppLocalizationsEn();
    final es = AppLocalizationsEs();
    expect(en.tvSeasonsLinkValue(5, 62), '5 · 62 episodes');
    expect(en.tvSeasonsLinkValue(1, 1), '1 · 1 episode');
    expect(es.tvSeasonsLinkValue(5, 62), '5 · 62 episodios');
    expect(es.tvSeasonsLinkValue(1, 1), '1 · 1 episodio');
  });
}
