import 'package:dio/dio.dart';

/// Inyecta el header `Authorization: Bearer <jwt>` en cada request y, si el
/// servidor responde 401, dispara [onUnauthorized] para que la capa que lo
/// configuró (ver [DioClient.setOnUnauthorized]) limpie la sesión.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.getToken, required this.onUnauthorized});

  final Future<String?> Function() getToken;
  final Future<void> Function() onUnauthorized;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await onUnauthorized();
    }
    handler.next(err);
  }
}
