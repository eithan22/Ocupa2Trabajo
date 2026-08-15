import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';

/// Adaptador web para reutilizar el mismo endpoint de uploads sin importar
/// dart:io, que no está disponible en Chrome.
Future<String> uploadContractPhotoPlatform(XFile file) async {
  try {
    final response = await DioClient.instance.dio.post(
      '/uploads',
      data: {
        'image': base64Encode(await file.readAsBytes()),
        'filename': file.name,
      },
    );
    final data = response.data is Map ? response.data['data'] : null;
    return data is Map && data['url'] is String ? data['url'] as String : '';
  } on DioException catch (e) {
    throw ApiException.fromDioException(e);
  }
}
