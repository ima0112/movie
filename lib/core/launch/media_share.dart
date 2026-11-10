import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../l10n/l10n_extension.dart';
import '../domain/entities/media_key.dart';
import '../domain/entities/media_type.dart';

/// The public TMDB page for [key] — what D1/D2's Share button sends. TMDB
/// redirects `/movie/{id}` and `/tv/{id}` to the canonical slug page.
String tmdbShareUrl(MediaKey key) {
  final kind = switch (key.type) {
    MediaType.movie => 'movie',
    MediaType.tvShow => 'tv',
  };
  return 'https://www.themoviedb.org/$kind/${key.tmdbId}';
}

/// The text the system share sheet receives: the title, then the link on its
/// own line. Language-neutral, so it needs no translation.
String mediaShareText({required String title, required MediaKey key}) =>
    '$title\n${tmdbShareUrl(key)}';

/// Opens the system share sheet with [title] and its TMDB link. On iPad the
/// sheet anchors to the widget that [context] belongs to; a failure shows a
/// snackbar instead of crashing.
Future<void> shareMedia(
  BuildContext context, {
  required String title,
  required MediaKey key,
}) async {
  final box = context.findRenderObject() as RenderBox?;
  final origin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;
  final messenger = ScaffoldMessenger.of(context);
  final failure = context.l10n.mediaDetailShareFailed;
  try {
    await SharePlus.instance.share(
      ShareParams(
        text: mediaShareText(title: title, key: key),
        sharePositionOrigin: origin,
      ),
    );
  } catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(failure)));
  }
}
