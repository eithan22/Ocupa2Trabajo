import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../../models/forum_model.dart';

class ForumRepository {
  ForumRepository({Dio? dio}) : _dio = dio ?? DioClient.instance.dio;

  final Dio _dio;

  Future<List<ForumTopicModel>> getTopics() async {
    try {
      final response = await _dio.get('/forum/topics');
      final data = _data(response.data);
      if (data is! List) return const [];

      return data
          .whereType<Map>()
          .map(
            (item) => ForumTopicModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<ForumTopicModel> getTopic(String id) async {
    try {
      final response = await _dio.get('/forum/topics/$id');
      final data = _data(response.data);
      if (data is! Map) {
        throw ApiException('El tema no tiene un formato válido.');
      }
      return ForumTopicModel.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<ForumTopicModel?> createTopic({
    required String title,
    required String body,
  }) async {
    try {
      final response = await _dio.post(
        '/forum/topics',
        data: {'title': title, 'description': body},
      );
      final data = _data(response.data);
      return data is Map
          ? ForumTopicModel.fromJson(Map<String, dynamic>.from(data))
          : null;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> addComment({
    required String topicId,
    required String body,
  }) async {
    try {
      await _dio.post('/forum/topics/$topicId/comments', data: {'body': body});
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  dynamic _data(dynamic responseData) {
    if (responseData is Map && responseData['data'] != null) {
      return responseData['data'];
    }
    return responseData;
  }
}
