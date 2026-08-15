import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../models/contract_model.dart';
import '../data/contracts_repository.dart';

class ContractsProvider extends ChangeNotifier {
  ContractsProvider({ContractsRepository? repository})
    : _repository = repository ?? ContractsRepository();

  final ContractsRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<ContractModel> _contracts = [];
  ContractModel? _currentContract;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ContractModel> get contracts => List.unmodifiable(_contracts);
  ContractModel? get currentContract => _currentContract;

  Future<void> loadContracts({String? status}) async {
    _begin();
    try {
      _contracts = await _repository.getMyContracts(status: status);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _finish();
    }
  }

  Future<void> loadContract(String id) async {
    _begin();
    try {
      _currentContract = await _repository.getContract(id);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _finish();
    }
  }

  Future<bool> setTerms({
    required String id,
    required double salary,
    required String currency,
    required DateTime startDate,
    required String duration,
  }) async {
    return _runAction(() async {
      await _repository.setTerms(
        id: id,
        salary: salary,
        currency: currency,
        startDate: startDate,
        duration: duration,
      );
      await _reload(id);
    });
  }

  Future<bool> accept(String id) => _runAction(() async {
    await _repository.accept(id);
    await _reload(id);
  });

  Future<bool> reject(String id) => _runAction(() async {
    await _repository.reject(id);
    await _reload(id);
  });

  Future<bool> addComment({required String id, required String body}) =>
      _runAction(() async {
        await _repository.addComment(id: id, body: body);
        await _reload(id);
      });

  Future<bool> addPhoto({
    required String id,
    required String photo,
    required String description,
  }) => _runAction(() async {
    await _repository.addPhoto(id: id, photo: photo, description: description);
    await _reload(id);
  });

  Future<bool> cancel({required String id, required String justification}) =>
      _runAction(() async {
        await _repository.cancel(id: id, justification: justification);
        await _reload(id);
      });

  Future<void> _reload(String id) async {
    _currentContract = await _repository.getContract(id);
  }

  Future<bool> _runAction(Future<void> Function() action) async {
    _begin();
    try {
      await action();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _finish();
    }
  }

  void _begin() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
  }

  void _finish() {
    _isLoading = false;
    notifyListeners();
  }
}
