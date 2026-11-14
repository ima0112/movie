import 'package:flutter/material.dart';

/// The app's one snackbar (`docs/SCREENS.md` G): a short message in the
/// floating pill `AppTheme` styles, with an optional action — "Undo" for what
/// can be undone. Every snackbar goes through here (a guard test fails on a
/// raw `SnackBar(`), so they all look and last the same.
///
/// The Scaffold lifts it above the floating tab bar on the root tabs; pushed
/// screens have no bar and show it at the bottom.
abstract final class AppSnackBar {
  /// How long it stays; long enough to reach for "Undo".
  static const Duration duration = Duration(seconds: 4);

  /// Shows [message] (replacing any snackbar already up). With [actionLabel]
  /// the pill carries a button that runs [onAction].
  static void show(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) => showOn(
    ScaffoldMessenger.of(context),
    message,
    actionLabel: actionLabel,
    onAction: onAction,
  );

  /// The same on a messenger taken earlier — for code that awaits first and so
  /// can't use its `context` afterwards.
  static void showOn(
    ScaffoldMessengerState messenger,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    assert(
      (actionLabel == null) == (onAction == null),
      'An action needs both a label and a callback',
    );
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: duration,
          action: actionLabel == null
              ? null
              : SnackBarAction(label: actionLabel, onPressed: onAction!),
        ),
      );
  }
}
