import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../network/api_exception.dart';
import '../network/dio_client.dart';

/// Sube una imagen al API (POST /uploads) y devuelve su URL pública.
/// Usado por Ofertas (foto obligatoria), Experiencias (certificado) y
/// Contratos (fotos con descripción) — no crear una versión propia en
/// cada módulo, siempre importar esta clase.
class UploadService {
  UploadService({Dio? dio}) : _dio = dio ?? DioClient.instance.dio;

  final Dio _dio;

  /// Sube [imageFile] en base64 y devuelve la URL pública que el API
  /// asigna. Lanza [ApiException] si el archivo es inválido (422) o si
  /// el servidor no pudo guardarlo (502).


  Future<String> uploadImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final filename = imageFile.path.split(Platform.pathSeparator).last;

      final response = await _dio.post(
        '/uploads',
        data: {'image': base64Image, 'filename': filename},
      );

      return response.data['data']['url'] as String;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}