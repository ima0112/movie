import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

import '../dio_failure_mapper.dart';
import '../network_status.dart';

/// Tells [NetworkStatus] what each request did: an answer — success or an
/// HTTP error — means the network is fine; a connection error or timeout
/// ([isUnreachable]) means it isn't. A cancelled request says nothing, and
/// neither does an answer served from the response cache.
class NetworkStatusInterceptor extends Interceptor {
  NetworkStatusInterceptor(this._status);

  final NetworkStatus _status;

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    // An answer the response cache handed back says nothing about the network.
    if (response.extra[extraFromNetworkKey] != false) {
      _status.reportReachable();
    }
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
