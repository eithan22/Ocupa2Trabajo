import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../models/job_type_model.dart';
import '../../../models/offer_model.dart';

class OffersRepository {
  final Dio _dio = DioClient.instance as Dio;


  Future<List<JobTypeModel>> getJobTypes() async {
    try {
      final response = await _dio.get('/job-types');
      final data = response.data as List;
      return data.map((e) => JobTypeModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al obtener tipos de empleo');
    }
  }


  Future<List<OfferModel>> getOffers({String? jobTypeKey, String? contractType}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (jobTypeKey != null && jobTypeKey.isNotEmpty) queryParams['jobTypeKey'] = jobTypeKey;
      if (contractType != null && contractType.isNotEmpty) queryParams['contractType'] = contractType;

      final response = await _dio.get('/offers', queryParameters: queryParams);
      final data = response.data as List;
      return data.map((e) => OfferModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al cargar las ofertas');
    }
  }


  Future<OfferModel> getOfferDetail(String id) async {
    try {
      final response = await _dio.get('/offers/$id');
      return OfferModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al cargar los detalles de la oferta');
    }
  }


  Future<List<OfferModel>> getMyOffers() async {
    try {
      final response = await _dio.get('/me/offers');
      final data = response.data as List;
      return data.map((e) => OfferModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al cargar tus ofertas');
    }
  }


  Future<OfferModel> createOffer(Map<String, dynamic> offerData) async {
    try {
      final response = await _dio.post('/offers', data: offerData);
      return OfferModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al publicar la oferta');
    }
  }
  
  Future<void> deactivateOffer(String id) async {
    try {
      await _dio.post('/offers/$id/deactivate');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al desactivar la oferta');
    }
  }
}