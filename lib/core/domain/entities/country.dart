/// One entry of H6's searchable country list — `docs/SCREENS.md` H6.
///
/// [code] is ISO 3166-1 alpha-2, the same shape `AppSettings.regionCode`
/// and TMDB's own `region`/`certification_country` parameters use —
/// picking a [Country] here is literally picking a new
/// `AppSettings.regionCode`.
class Country {
  const Country({required this.code, required this.name});

  final String code;
  final String name;

  @override
  bool operator ==(Object other) =>
      other is Country && other.code == code && other.name == name;

  @override
  int get hashCode => Object.hash(code, name);

  @override
  String toString() => 'Country($code, $name)';
}

/// A practical (not exhaustively ISO-complete) list of countries for
/// H6's region picker — every country this app's own
/// Spanish-speaking-region logic (`tmdbLanguageTag`) already names,
/// plus the rest of the world's most commonly selected regions.
/// Alphabetical by [Country.name], so the list reads sensibly even
/// before anything is typed into H6's own search field.
const List<Country> countryCatalog = [
  Country(code: 'AR', name: 'Argentina'),
  Country(code: 'AU', name: 'Australia'),
  Country(code: 'AT', name: 'Austria'),
  Country(code: 'BE', name: 'Belgium'),
  Country(code: 'BO', name: 'Bolivia'),
  Country(code: 'BR', name: 'Brazil'),
  Country(code: 'CA', name: 'Canada'),
  Country(code: 'CL', name: 'Chile'),
  Country(code: 'CO', name: 'Colombia'),
  Country(code: 'CR', name: 'Costa Rica'),
  Country(code: 'CU', name: 'Cuba'),
  Country(code: 'DK', name: 'Denmark'),
  Country(code: 'DO', name: 'Dominican Republic'),
  Country(code: 'EC', name: 'Ecuador'),
  Country(code: 'SV', name: 'El Salvador'),
  Country(code: 'FI', name: 'Finland'),
  Country(code: 'FR', name: 'France'),
  Country(code: 'DE', name: 'Germany'),
  Country(code: 'GT', name: 'Guatemala'),
  Country(code: 'HN', name: 'Honduras'),
  Country(code: 'IN', name: 'India'),
  Country(code: 'IE', name: 'Ireland'),
  Country(code: 'IT', name: 'Italy'),
  Country(code: 'JP', name: 'Japan'),
  Country(code: 'MX', name: 'Mexico'),
  Country(code: 'NL', name: 'Netherlands'),
  Country(code: 'NZ', name: 'New Zealand'),
  Country(code: 'NI', name: 'Nicaragua'),
  Country(code: 'NO', name: 'Norway'),
  Country(code: 'PA', name: 'Panama'),
  Country(code: 'PY', name: 'Paraguay'),
  Country(code: 'PE', name: 'Peru'),
  Country(code: 'PL', name: 'Poland'),
  Country(code: 'PT', name: 'Portugal'),
  Country(code: 'PR', name: 'Puerto Rico'),
  Country(code: 'KR', name: 'South Korea'),
  Country(code: 'ES', name: 'Spain'),
  Country(code: 'SE', name: 'Sweden'),
  Country(code: 'CH', name: 'Switzerland'),
  Country(code: 'GB', name: 'United Kingdom'),
  Country(code: 'US', name: 'United States'),
  Country(code: 'UY', name: 'Uruguay'),
  Country(code: 'VE', name: 'Venezuela'),
];

/// [code]'s display name from [countryCatalog] — e.g. for D1/D2's
/// "Where to watch" region label, which this app's current, practical
/// (not ISO-complete) catalog doesn't cover every possible code for.
/// Falls back to the bare code itself rather than throwing, so an
/// unrecognized `AppSettings.regionCode` degrades to showing "US"
/// instead of crashing the screen that reads it.
String countryName(String code) =>
    countryCatalog.firstWhere((c) => c.code == code, orElse: () => Country(code: code, name: code)).name;
