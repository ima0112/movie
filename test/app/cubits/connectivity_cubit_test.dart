import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/cubits/connectivity_cubit.dart';
import 'package:movies/core/network/network_status.dart';

void main() {
  test('mirrors NetworkStatus: online at first, then every flip', () async {
    final status = NetworkStatus();
    final cubit = ConnectivityCubit(status);
    addTearDown(cubit.close);
    final seen = <bool>[];
    cubit.stream.listen(seen.add);

    expect(cubit.state, isTrue);
    status.reportUnreachable();
    status.reportReachable();
    await Future<void>.delayed(Duration.zero);

    expect(seen, [false, true]);
  });

  test('starts offline when it already is', () {
    final cubit = ConnectivityCubit(NetworkStatus()..reportUnreachable());
    addTearDown(cubit.close);

    expect(cubit.state, isFalse);
  });
}
