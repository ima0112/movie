import 'package:flutter/material.dart';

import '../core/domain/entities/result.dart';
import '../core/domain/entities/user_media_entry.dart';
import '../core/domain/repositories/user_library_repository.dart';
import '../l10n/l10n_extension.dart';
import 'widgets/app_snack_bar.dart';

/// Saves [next] to My List and tells the user how it went — the one way the
/// app writes an entry from a screen, so no write is silent:
///
/// - it failed → the "couldn't save that" snackbar (`failureStorage`), nothing
///   else;
/// - it worked and [message] is given → that snackbar with "Undo", which
///   restores [previous] (what was stored before; `null` if the title wasn't
///   in My List, in which case Undo deletes it).
///
/// [context] is only read before the first `await`, so it is safe to call from
/// a widget that is gone by the time the write finishes.
Future<void> saveEntry(
  BuildContext context,
  UserLibraryRepository repository,
  UserMediaEntry next, {
  UserMediaEntry? previous,
  String? message,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final result = await repository.upsert(next);
  if (result is Failure<void>) {
    AppSnackBar.showOn(messenger, l10n.failureStorage);
    return;
  }
  if (message == null) return;
  AppSnackBar.showOn(
    messenger,
    message,
    actionLabel: l10n.myListUndoAction,
    onAction: () => previous == null
        ? repository.remove(next.key)
        : repository.upsert(previous),
  );
}
