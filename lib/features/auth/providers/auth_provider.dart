import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../models/user_model.dart';
import '../data/auth_repository.dart';

/// Estado de la última acción disparada por el usuario (registrar, iniciar
/// sesión, etc.). No confundir con [AuthProvider.isBootstrapping], que
/// cubre la resolución de la sesión guardada al arrancar la app.
enum AuthStatus { idle, loading, error }

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthRepository? repository, SecureStorageService? storage})
    : _repository = repository ?? AuthRepository(),
      _storage = storage ?? SecureStorageService();

  final AuthRepository _repository;
  final SecureStorageService _storage;

  AuthStatus _status = AuthStatus.idle;
  String? _errorMessage;
  UserModel? _currentUser;
  bool _isBootstrapping = true;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;
  bool get isBootstrapping => _isBootstrapping;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isLoggedIn => _currentUser != null;
  bool get isProfileCompleted => _currentUser?.profileCompleted ?? false;

  /// Se llama una sola vez al arrancar la app. Lee el JWT guardado y, si
  /// existe, valida la sesión contra `GET /me`.
  Future<void> bootstrap() async {
    final token = await _storage.getToken();
    if (token == null || token.isEmpty) {
      _isBootstrapping = false;
      notifyListeners();
      return;
    }
    try {
      _currentUser = await _repository.getMe();
    } on ApiException {
      await _storage.clearToken();
      _currentUser = null;
    } finally {
      _isBootstrapping = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String referralMatricula,
  }) {
    return _runAction(() async {
      final result = await _repository.register(
        email: email,
        firstName: firstName,
        lastName: lastName,
        password: password,
        referralMatricula: referralMatricula,
      );
      await _storage.saveToken(result.token);
      _currentUser = result.user;
    });
  }

  Future<bool> login({required String email, required String password}) {
    return _runAction(() async {
      final result = await _repository.login(email: email, password: password);
      await _storage.saveToken(result.token);
      _currentUser = result.user;
    });
  }

  Future<bool> forgotPassword({required String email, required String referralMatricula}) {
    return _runAction(
      () => _repository.forgotPassword(email: email, referralMatricula: referralMatricula),
    );
  }

  Future<bool> loadMe() {
    return _runAction(() async {
      _currentUser = await _repository.getMe();
    });
  }

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String cedula,
    required String gender,
    required DateTime birthDate,
  }) {
    return _runAction(() async {
      _currentUser = await _repository.updateProfile(
        firstName: firstName,
        lastName: lastName,
        cedula: cedula,
        gender: gender,
        birthDate: birthDate,
      );
    });
  }

  Future<bool> changePassword({required String password}) {
    return _runAction(() => _repository.changePassword(password: password));
  }

  Future<void> logout() async {
    await _storage.clearToken();
    _currentUser = null;
    _status = AuthStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  /// Llamado por [DioClient] cuando un request responde 401.
  void handleUnauthorized() {
    _currentUser = null;
    _errorMessage = 'Sesión expirada. Inicia sesión de nuevo.';
    notifyListeners();
  }

  Future<bool> _runAction(Future<void> Function() action) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
      _status = AuthStatus.idle;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }
}
