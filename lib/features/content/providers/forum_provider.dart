import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../models/forum_model.dart';
import '../data/forum_repository.dart';

class ForumProvider extends ChangeNotifier {
  ForumProvider({ForumRepository? repository})
    : _repository = repository ?? ForumRepository();

  final ForumRepository _repository;

  List<ForumTopicModel> _topics = [];
  ForumTopicModel? _selectedTopic;
  bool _isLoadingTopics = false;
  bool _isLoadingTopic = false;
  bool _isSubmitting = false;
  String? _topicsError;
  String? _topicError;

  List<ForumTopicModel> get topics => _topics;
  ForumTopicModel? get selectedTopic => _selectedTopic;
  bool get isLoadingTopics => _isLoadingTopics;
  bool get isLoadingTopic => _isLoadingTopic;
  bool get isSubmitting => _isSubmitting;
  String? get topicsError => _topicsError;
  String? get topicError => _topicError;

  Future<void> loadTopics() async {
    _isLoadingTopics = true;
    _topicsError = null;
    notifyListeners();

    try {
      _topics = await _repository.getTopics();
    } on ApiException catch (e) {
      _topicsError = e.message;
    } finally {
      _isLoadingTopics = false;
      notifyListeners();
    }
  }

  Future<void> loadTopic(String id) async {
    _isLoadingTopic = true;
    _topicError = null;
    _selectedTopic = null;
    notifyListeners();

    try {
      _selectedTopic = await _repository.getTopic(id);
    } on ApiException catch (e) {
      _topicError = e.message;
    } finally {
      _isLoadingTopic = false;
      notifyListeners();
    }
  }

  Future<bool> createTopic({
    required String title,
    required String body,
  }) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      final topic = await _repository.createTopic(title: title, body: body);
      if (topic != null) {
        _topics = [topic, ..._topics.where((item) => item.id != topic.id)];
      } else {
        await loadTopics();
      }
      return true;
    } on ApiException catch (e) {
      _topicsError = e.message;
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> addComment({
    required String topicId,
    required String body,
  }) async {
    _isSubmitting = true;
    notifyListeners();

    try {
      await _repository.addComment(topicId: topicId, body: body);
      await loadTopic(topicId);
      return true;
    } on ApiException catch (e) {
      _topicError = e.message;
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
