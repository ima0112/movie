import '../domain/entities/media_key.dart';
import '../domain/entities/media_type.dart';

/// The links that open **this app** on a title, as D1/D2's Share sends them.
///
/// Today they use the app's own URL scheme — `pakotv://app/movie/603`,
/// `pakotv://app/tv/1396` — which works on a device that has the app and needs
/// no server. The host is a placeholder (`app`) on purpose: Flutter hands the
/// router only the URI's **path**, so `pakotv://movie/603` would reach it as
/// `/603` and lose the kind of title. The path part (`/movie/603`) is the app's
/// own route, so the day the links become `https://<domain>/movie/603` only
/// [appLinkScheme] and [appLinkHost] change.
///
/// Pure — no Flutter, no platform code. The Android intent filter and the iOS
/// `CFBundleURLTypes` entry that make the system deliver these links live in the
/// platform projects and must use the same [appLinkScheme] and [appLinkHost].
const String appLinkScheme = 'pakotv';
const String appLinkHost = 'app';

const String _movieSegment = 'movie';
const String _tvSegment = 'tv';

/// The link that opens [key]'s detail in the app.
Uri appLinkFor(MediaKey key) => Uri(
  scheme: appLinkScheme,
  host: appLinkHost,
  pathSegments: [
    switch (key.type) {
      MediaType.movie => _movieSegment,
      MediaType.tvShow => _tvSegment,
    },
    '${key.tmdbId}',
  ],
);

/// The title a received [link] points at, or `null` when it isn't one of ours
/// (another scheme or host, an unknown kind of title, a missing or non-numeric
/// id, extra path segments). Never throws: a garbled link is just not a link.
MediaKey? mediaKeyFromAppLink(Uri link) {
  if (link.scheme != appLinkScheme || link.host != appLinkHost) return null;
  final segments = link.pathSegments;
  if (segments.length != 2) return null;
  final id = int.tryParse(segments[1]);
  if (id == null || id <= 0) return null;
  final type = switch (segments[0]) {
    _movieSegment => MediaType.movie,
    _tvSegment => MediaType.tvShow,
    _ => null,
  };
  return type == null ? null : MediaKey(type: type, tmdbId: id);
}
