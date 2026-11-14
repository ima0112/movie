import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/network/network_status.dart';

/// Whether the app is online (`true`) or its last request couldn't reach the
/// server (`false`) — what the offline banner reads.
///
/// **Global** (provided in `app/app.dart`, CLAUDE.md rule 10): the connection
/// outlives any screen and Home and Explore, unrelated to each other, both
/// react to it. It just mirrors [NetworkStatus].
class ConnectivityCubit extends Cubit<bool> {
  ConnectivityCubit(NetworkStatus status) : super(status.isOnline) {
    _subscription = status.changes.listen(emit);
  }

  late final StreamSubscription<bool> _subscription;

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
