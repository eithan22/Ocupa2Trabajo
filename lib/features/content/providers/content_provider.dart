import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../models/news_item_model.dart';
import '../../../models/video_model.dart';
import '../data/content_repository.dart';

class ContentProvider extends ChangeNotifier {
  ContentProvider({ContentRepository? repository}) : _repository = repository ?? ContentRepository();

  final ContentRepository _repository;

  List<NewsItemModel> _news = [];
  bool _isLoadingNews = false;
  String? _newsError;

  List<NewsItemModel> get news => _news;
  bool get isLoadingNews => _isLoadingNews;
  String? get newsError => _newsError;

  Future<void> loadNews() async {
    _isLoadingNews = true;
    _newsError = null;
    notifyListeners();

    try {
      _news = await _repository.getNews();
    } on ApiException catch (e) {
      _newsError = e.message;
    } finally {
      _isLoadingNews = false;
      notifyListeners();
    }
  }

  List<VideoModel> _videos = [];
  bool _isLoadingVideos = false;
  String? _videosError;

  List<VideoModel> get videos => _videos;
  bool get isLoadingVideos => _isLoadingVideos;
  String? get videosError => _videosError;

  Future<void> loadVideos() async {
    _isLoadingVideos = true;
    _videosError = null;
    notifyListeners();

    try {
      _videos = await _repository.getVideos();
    } on ApiException catch (e) {
      _videosError = e.message;
    } finally {
      _isLoadingVideos = false;
      notifyListeners();
    }
  }


}