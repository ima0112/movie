import 'dart:async';

import 'package:injectable/injectable.dart';

/// Whether the app's last request to the network got through — the source of
/// the offline banner (`docs/SCREENS.md` G).
///
/// There is no connectivity plugin: [NetworkStatusInterceptor] reports what
/// every TMDB request actually did, so "offline" means "the last request could
/// not reach the server" and clears with the next one that does. Starts online
/// (nothing has failed yet), and stays so where nothing reports at all (the
/// `fake` environment never touches the network).
///
/// `@LazySingleton`, registered in every environment: the interceptor writes
/// it and the global `ConnectivityCubit` reads it.
@LazySingleton()
class NetworkStatus {
  bool _online = true;
  final StreamController<bool> _changes = StreamController<bool>.broadcast();

  bool get isOnline => _online;

  /// Emits only when [isOnline] flips.
  Stream<bool> get changes => _changes.stream;

  /// A request got an answer from the server (any status).
  void reportReachable() => _set(true);

  /// A request could not reach the server (no connection, timeout).
  void reportUnreachable() => _set(false);

  void _set(bool online) {
    if (_online == online) return;
    _online = online;
    _changes.add(online);
  }
}
