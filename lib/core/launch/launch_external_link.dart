import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'youtube_urls.dart';

/// Opens a trailer's own YouTube video — the YouTube app's `youtube://`
/// scheme first, the regular watch-page URL in the external browser if
/// that fails (app not installed, or anything else `launchUrl` can't
/// handle). Never lets a launch failure surface as an exception — shows
/// a discreet snackbar instead if *nothing* could be opened.
///
/// `docs/SCREENS.md` D1: "Trailer button... opens YouTube: app scheme,
/// then browser."
Future<void> launchYoutubeTrailer(BuildContext context, String videoKey) =>
    _launchFirstWorking(context, youtubeTrailerUris(videoKey));

/// Opens [url] (a TMDB-provided watch-provider link, or any other plain
/// external link) in the external browser. Same "never throws, snackbar
/// on total failure" contract as [launchYoutubeTrailer].
Future<void> launchExternalLink(BuildContext context, String url) =>
    _launchFirstWorking(context, [Uri.parse(url)]);

Future<void> _launchFirstWorking(
  BuildContext context,
  List<Uri> candidates,
) async {
  for (final uri in candidates) {
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return;
    } catch (_) {
      // This candidate failed (e.g. no app registered for the scheme) —
      // try the next one rather than giving up.
    }
  }
  if (context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Couldn't open that link")));
  }
}
