import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../../models/contract_model.dart';

class ContractsRepository {
  ContractsRepository({Dio? dio}) : _dio = dio ?? DioClient.instance.dio;

  final Dio _dio;

  Future<List<ContractModel>> getMyContracts({String? status}) async {
    try {
      final response = await _dio.get(
        '/me/contracts',
        queryParameters: status == null ? null : {'status': status},
      );
      final data = _data(response.data);
      if (data is! List) return const [];
      return data
          .whereType<Map>()
          .map(
            (item) => ContractModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<ContractModel> getContract(String id) async {
    try {
      final response = await _dio.get('/contracts/$id');
      return ContractModel.fromJson(_asMap(_data(response.data)));
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> setTerms({
    required String id,
    required double salary,
    required String currency,
    required DateTime startDate,
    required String duration,
  }) async {
    try {
      await _dio.put(
        '/contracts/$id/terms',
        data: {
          'salary': salary,
          'currency': currency,
          'startDate': _dateOnly(startDate),
          'duration': duration,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> accept(String id) => _postAction('/contracts/$id/accept');

  Future<void> reject(String id) => _postAction('/contracts/$id/reject');

  Future<void> addComment({required String id, required String body}) async {
    try {
      await _dio.post('/contracts/$id/comments', data: {'body': body});
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> addPhoto({
    required String id,
    required String photo,
    required String description,
  }) async {
    try {
      await _dio.post(
        '/contracts/$id/photos',
        data: {'photo': photo, 'description': description},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> cancel({
    required String id,
    required String justification,
  }) async {
    try {
      await _dio.post(
        '/contracts/$id/cancel',
        data: {'justification': justification},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> _postAction(String path) async {
    try {
      await _dio.post(path);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  static dynamic _data(dynamic response) {
    if (response is Map && response.containsKey('data')) {
      return response['data'];
    }
    return response;
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    return value is Map
        ? Map<String, dynamic>.from(value)
        : <String, dynamic>{};
  }

  static String _dateOnly(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
