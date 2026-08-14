import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../../models/user_model.dart';

/// Resultado de `/auth/register` y `/auth/login`: token + usuario.
class AuthResult {
  const AuthResult({required this.token, required this.tokenType, required this.user});

  final String token;
  final String tokenType;
  final UserModel user;

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      token: json['token'] as String,
      tokenType: json['tokenType'] as String? ?? 'Bearer',
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

/// Llamadas crudas al API de auth y perfil. Devuelve modelos de dominio o
/// lanza [ApiException].
class AuthRepository {
  AuthRepository({Dio? dio}) : _dio = dio ?? DioClient.instance.dio;

  final Dio _dio;

  Future<AuthResult> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String referralMatricula,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'password': password,
          'referralMatricula': referralMatricula,
        },
      );
      return AuthResult.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<AuthResult> login({required String email, required String password}) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return AuthResult.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> forgotPassword({required String email, required String referralMatricula}) async {
    try {
      await _dio.post(
        '/auth/forgot-password',
        data: {'email': email, 'referralMatricula': referralMatricula},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<UserModel> getMe() async {
    try {
      final response = await _dio.get('/me');
      return UserModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<UserModel> updateProfile({
    required String firstName,
    required String lastName,
    required String cedula,
    required String gender,
    required DateTime birthDate,
  }) async {
    try {
      final response = await _dio.put(
        '/me/profile',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'cedula': cedula,
          'gender': gender,
          'birthDate': DateFormat('yyyy-MM-dd').format(birthDate),
        },
      );
      return UserModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// El API solo acepta la clave nueva; no valida ni pide la clave actual.
  Future<void> changePassword({required String password}) async {
    try {
      await _dio.put('/me/password', data: {'password': password});
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
