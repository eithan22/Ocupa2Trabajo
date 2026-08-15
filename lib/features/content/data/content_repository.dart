import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../../models/news_item_model.dart';
import '../../../models/video_model.dart';

class ContentRepository {
  ContentRepository({Dio? dio}) : _dio = dio ?? DioClient.instance.dio;

  final Dio _dio;

  Future<List<NewsItemModel>> getNews({int limit = 12}) async {
    try {
      final response = await _dio.get('/news', queryParameters: {'limit': limit});
      final List data = response.data['data'] as List;
      return data.map((json) => NewsItemModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<VideoModel>> getVideos() async {
    try {
      final response = await _dio.get('/videos');
      final List data = response.data['data'] as List;
      return data.map((json) => VideoModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}