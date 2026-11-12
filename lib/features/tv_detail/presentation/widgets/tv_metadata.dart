import 'package:flutter/widgets.dart';

import '../../../../core/domain/entities/media_detail.dart';
import '../../../../l10n/locale_names.dart';

/// "2008–2013" (first–last air year), or just "2008" when they match or the
/// last one isn't known; `null` with no first air date.
String? tvYearRange(TvShowDetail detail) {
  final firstYear = detail.firstAirDate?.year;
  final lastYear = detail.lastAirDate?.year;
  return switch (firstYear) {
    null => null,
    final f when lastYear == null || lastYear == f => '$f',
    final f => '$f–$lastYear',
  };
}

/// D2's info-card text before the genres: "2008–2013 · United States" — the
/// air years and the main origin country's name in the app's language
/// (`flutter_localized_locales`). Seasons, episodes and the status live in
/// the cards under the info card instead (`docs/SCREENS.md` D2).
String tvMetaPrefix(BuildContext context, TvShowDetail detail) => [
  ?tvYearRange(detail),
  if (detail.countryCodes.isNotEmpty)
    countryDisplayName(context, detail.countryCodes.first),
].join(' · ');
