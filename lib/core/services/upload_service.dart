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
    return uploadImageBytes(
      bytes: await imageFile.readAsBytes(),
      filename: imageFile.path.split(Platform.pathSeparator).last,
    );
  }

  /// Sube bytes de imagen para clientes multiplataforma como [XFile].
  /// Valida las reglas de negocio del API antes de realizar la solicitud.
  Future<String> uploadImageBytes({
    required List<int> bytes,
    required String filename,
  }) async {
    const maxBytes = 8 * 1024 * 1024;
    const allowedExtensions = {'jpg', 'jpeg', 'png', 'webp', 'gif'};
    final extension = filename.contains('.')
        ? filename.split('.').last.toLowerCase()
        : '';

    if (bytes.isEmpty) {
      throw ApiException('El archivo de imagen está vacío.');
    }
    if (bytes.length > maxBytes) {
      throw ApiException('La imagen no puede superar los 8 MB.');
    }
    if (!allowedExtensions.contains(extension)) {
      throw ApiException('Formato no permitido. Usa JPG, PNG, WEBP o GIF.');
    }

    try {
      final base64Image = base64Encode(bytes);

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
