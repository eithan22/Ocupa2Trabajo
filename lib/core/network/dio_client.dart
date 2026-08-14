import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../config/api_config.dart';
import '../storage/secure_storage_service.dart';
import 'auth_interceptor.dart';

/// Cliente Dio único para toda la app. Todos los módulos deben usar
/// `DioClient.instance.dio` en vez de crear su propia instancia de [Dio],
/// para compartir baseUrl, timeouts, el interceptor de JWT y el logger.
class DioClient {
  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: const {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      AuthInterceptor(
        getToken: _storage.getToken,
        onUnauthorized: () async {
          await _storage.clearToken();
          _onUnauthorized?.call();
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(requestBody: true, responseBody: true, requestHeader: false),
      );
    }
  }

  static final DioClient instance = DioClient._internal();

  late final Dio _dio;
  final SecureStorageService _storage = SecureStorageService();
  VoidCallback? _onUnauthorized;

  Dio get dio => _dio;

  /// Se llama una vez desde `app.dart` para que, cuando el interceptor
  /// detecte un 401, se notifique a [AuthProvider] y el router redirija a
  /// `/login`.
  void setOnUnauthorized(VoidCallback callback) {
    _onUnauthorized = callback;
  }
}
