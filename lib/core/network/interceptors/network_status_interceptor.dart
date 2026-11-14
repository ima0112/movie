import 'package:dio/dio.dart';

import '../dio_failure_mapper.dart';
import '../network_status.dart';

/// Tells [NetworkStatus] what each request did: an answer — success or an
/// HTTP error — means the network is fine; a connection error or timeout
/// ([isUnreachable]) means it isn't. A cancelled request says nothing.
class NetworkStatusInterceptor extends Interceptor {
  NetworkStatusInterceptor(this._status);

  final NetworkStatus _status;

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _status.reportReachable();
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (isUnreachable(err)) {
      _status.reportUnreachable();
    } else if (err.response != null) {
      _status.reportReachable();
    }
    handler.next(err);
  }
}
