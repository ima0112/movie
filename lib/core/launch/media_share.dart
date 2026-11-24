import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../l10n/l10n_extension.dart';
import '../../shared/widgets/app_snack_bar.dart';
import '../domain/entities/media_key.dart';
import 'app_link.dart';

/// The text the system share sheet receives: the title, then the link that
/// opens the title in this app (`appLinkFor`) on its own line. Language-neutral,
/// so it needs no translation.
String mediaShareText({required String title, required MediaKey key}) =>
    '$title\n${appLinkFor(key)}';

/// Opens the system share sheet with [title] and its link into this app. On iPad the
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
    AppSnackBar.showOn(messenger, failure);
  }
}
