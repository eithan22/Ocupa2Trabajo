import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../models/job_type_model.dart';
import '../../../models/offer_model.dart';

class OffersRepository {
  final Dio _dio = DioClient.instance.dio;

  Future<List<JobTypeModel>> getJobTypes() async {
    try {
      final response = await _dio.get('/job-types');
      final data = _extractList(response.data);
      if (data is! List) {
        throw Exception(
          'La respuesta de tipos de empleo no tiene un formato válido',
        );
      }
      return data
          .whereType<Map>()
          .map((e) => JobTypeModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error al obtener tipos de empleo',
      );
    }
  }

  dynamic _extractList(dynamic responseData) {
    if (responseData is List) return responseData;
    if (responseData is Map) {
      final nested =
          responseData['data'] ??
          responseData['items'] ??
          responseData['jobTypes'] ??
          responseData['job_types'];
      if (nested is Map) return _extractList(nested);
      return nested;
    }
    return null;
  }

  Future<List<OfferModel>> getOffers({
    String? jobTypeKey,
    String? contractType,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (jobTypeKey != null && jobTypeKey.isNotEmpty) {
        queryParams['jobTypeKey'] = jobTypeKey;
      }
      if (contractType != null && contractType.isNotEmpty) {
        queryParams['contractType'] = contractType;
      }

      final response = await _dio.get('/offers', queryParameters: queryParams);
      final data = _extractList(response.data);
      if (data is! List) {
        throw Exception('La respuesta de ofertas no tiene un formato válido');
      }
      return data
          .whereType<Map>()
          .map((e) => OfferModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error al cargar las ofertas',
      );
    }
  }

  Future<OfferModel> getOfferDetail(String id) async {
    try {
      final response = await _dio.get('/offers/$id');
      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;
      return OfferModel.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ??
            'Error al cargar los detalles de la oferta',
      );
    }
  }

  Future<List<OfferModel>> getMyOffers() async {
    try {
      final response = await _dio.get('/me/offers');
      final data = _extractList(response.data);
      if (data is! List) {
        throw Exception(
          'La respuesta de tus ofertas no tiene un formato válido',
        );
      }
      return data
          .whereType<Map>()
          .map((e) => OfferModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error al cargar tus ofertas',
      );
    }
  }

  Future<OfferModel> createOffer(Map<String, dynamic> offerData) async {
    try {
      final response = await _dio.post('/offers', data: offerData);
      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;
      return OfferModel.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error al publicar la oferta',
      );
    }
  }

  Future<void> deactivateOffer(String id) async {
    try {
      await _dio.post('/offers/$id/deactivate');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error al desactivar la oferta',
      );
    }
  }
}
