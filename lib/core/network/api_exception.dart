import 'package:dio/dio.dart';

/// Excepción de dominio que traduce un [DioException] a un mensaje en
/// español listo para mostrar en la UI. El resto de los módulos deben
/// capturar [DioException] en su capa de datos y relanzar
/// [ApiException.fromDioException] en su lugar.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  factory ApiException.fromDioException(DioException e) {
    final statusCode = e.response?.statusCode;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return ApiException(
          'La conexión tardó demasiado. Verifica tu internet e intenta de nuevo.',
          statusCode: statusCode,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          'No hay conexión a internet. Verifica tu red e intenta de nuevo.',
          statusCode: statusCode,
        );
      case DioExceptionType.badCertificate:
        return ApiException(
          'No se pudo establecer una conexión segura con el servidor.',
          statusCode: statusCode,
        );
      case DioExceptionType.cancel:
        return ApiException('La solicitud fue cancelada.', statusCode: statusCode);
      case DioExceptionType.badResponse:
        return ApiException(_messageForStatus(statusCode, e), statusCode: statusCode);
      case DioExceptionType.unknown:
        return ApiException(
          'Ocurrió un error inesperado. Intenta de nuevo.',
          statusCode: statusCode,
        );
    }
  }

  static String _messageForStatus(int? statusCode, DioException e) {
    final apiMessage = _extractApiMessage(e.response?.data);

    switch (statusCode) {
      case 401:
        return apiMessage ?? 'Sesión expirada. Inicia sesión de nuevo.';
      case 402:
        return apiMessage ?? 'El pago fue rechazado.';
      case 403:
        return apiMessage ?? 'No tienes permiso para realizar esta acción.';
      case 404:
        return apiMessage ?? 'No se encontró el recurso solicitado.';
      case 409:
        return apiMessage ?? 'El correo ya está registrado.';
      case 422:
        return apiMessage ?? 'Algunos datos no son válidos. Revisa el formulario.';
      case 500:
      case 502:
      case 503:
        return apiMessage ?? 'El servidor tuvo un problema. Intenta más tarde.';
      default:
        return apiMessage ?? 'Ocurrió un error al procesar la solicitud.';
    }
  }

  /// El API responde errores como `{ "ok": false, "error": "<mensaje>" }`.
  static String? _extractApiMessage(dynamic data) {
    if (data is Map && data['error'] is String) {
      return data['error'] as String;
    }
    return null;
  }

  @override
  String toString() => message;
}
