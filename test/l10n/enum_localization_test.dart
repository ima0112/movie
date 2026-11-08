import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/discover_filter.dart';
import 'package:movies/core/domain/entities/genre_catalog.dart';
import 'package:movies/core/domain/entities/media_segment.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/result.dart';
import 'package:movies/core/domain/repositories/user_library_repository.dart';
import 'package:movies/features/match_engine/domain/vibe_catalog.dart';
import 'package:movies/features/person_detail/presentation/widgets/filmography_grouping.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/l10n/app_localizations_en.dart';
import 'package:movies/l10n/app_localizations_es.dart';
import 'package:movies/l10n/discover_sort_by_localization.dart';
import 'package:movies/l10n/failure_localization.dart';
import 'package:movies/l10n/filmography_segment_localization.dart';
import 'package:movies/l10n/genre_localization.dart';
import 'package:movies/l10n/library_tab_localization.dart';
import 'package:movies/l10n/media_segment_localization.dart';
import 'package:movies/l10n/media_type_localization.dart';
import 'package:movies/l10n/tv_status_localization.dart';
import 'package:movies/l10n/vibe_localization.dart';

/// CLAUDE.md rule 15: every value of every visible enum must resolve to
/// a real translation in both of this app's languages — never throw,
/// never fall through to an empty string. Each `expect` below exercises
/// every single enum value (not just "the extension compiles") against
/// both [AppLocalizationsEn] and [AppLocalizationsEs] directly — no
/// widget tree needed, since both are plain, publicly constructible
/// classes.
void main() {
  final en = AppLocalizationsEn();
  final es = AppLocalizationsEs();

  void expectLocalized(String Function(AppLocalizations) localize) {
    expect(localize(en), isNotEmpty);
    expect(localize(es), isNotEmpty);
  }

  group('FailureReason', () {
    for (final reason in FailureReason.values) {
      test('$reason has a key in both languages', () {
        expectLocalized((l10n) => reason.localizedMessage(l10n));
      });
    }
  });

  group('Genre', () {
    for (final genre in GenreCatalog.all) {
      test('${genre.id} has a key in both languages', () {
        expectLocalized((l10n) => genre.localizedName(l10n));
      });
    }
  });

  group('Vibe', () {
    final source = File('assets/vibes.json').readAsStringSync();
    final catalog = VibeCatalog.fromJsonString(source);

    for (final vibe in catalog.all()) {
      test('${vibe.id} has a key in both languages', () {
        expectLocalized((l10n) => vibe.localizedName(l10n));
      });
    }
  });

  group('MediaType', () {
    for (final type in MediaType.values) {
      test('$type has a singular and plural key in both languages', () {
        expectLocalized((l10n) => type.localizedSingular(l10n));
        expectLocalized((l10n) => type.localizedPlural(l10n));
      });
    }
  });

  group('MediaSegment', () {
    for (final segment in MediaSegment.values) {
      test('$segment has a key in both languages', () {
        expectLocalized((l10n) => segment.localizedLabel(l10n));
      });
    }
  });

  group('FilmographySegment', () {
    for (final segment in FilmographySegment.values) {
      test('$segment has a key in both languages', () {
        expectLocalized((l10n) => segment.localizedLabel(l10n));
      });
    }
  });

  group('DiscoverSortBy', () {
    for (final sortBy in DiscoverSortBy.values) {
      test('$sortBy has a key in both languages', () {
        expectLocalized((l10n) => sortBy.localizedLabel(l10n));
      });
    }
  });

  group('DiscoverTvStatus', () {
    for (final status in DiscoverTvStatus.values) {
      test('$status has a key in both languages', () {
        expectLocalized((l10n) => status.localizedLabel(l10n));
      });
    }
  });

  group('LibraryTab', () {
    for (final tab in LibraryTab.values) {
      test('$tab has a label, removed-message, and empty-headline key in '
          'both languages', () {
        expectLocalized((l10n) => tab.localizedLabel(l10n));
        expectLocalized((l10n) => tab.localizedRemovedMessage(l10n));
        expectLocalized((l10n) => tab.localizedEmptyHeadline(l10n));
      });
    }
  });
}
