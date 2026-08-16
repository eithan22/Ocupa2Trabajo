import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/services/upload_service.dart';
import '../../../models/application_model.dart';
import '../../../models/dynamic_field_model.dart';
import '../../../models/experience_model.dart';
import 'liked_offer_model.dart';

/// Capa de datos del módulo "Aplicaciones y Experiencias" (Persona 3).
///
/// Agrupa TODOS los endpoints listados en el README para este módulo:
///  - /me/experiences        (GET, POST, DELETE)
///  - /offers/{id}/apply     (POST)
///  - /offers/{id}/applications (GET)
///  - /me/applications       (GET)
///  - /applications/{id}     (PATCH)
///  - /offers/{id}/like      (POST, DELETE)
///  - /me/likes              (GET)
class ApplicationsRepository {
  final Dio _dio = DioClient.instance.dio;
  final UploadService _uploadService = UploadService();

  // ---------------------------------------------------------------------
  // Experiencias (Mi perfil / experiencias)
  // ---------------------------------------------------------------------

  Future<List<ExperienceModel>> getMyExperiences() async {
    try {
      final response = await _dio.get('/me/experiences');
      final data = response.data;
      final list = data is List
          ? data
          : data is Map
          ? (data['data'] ?? data['experiences'] ?? [])
          : [];
      return list
          .whereType<Map>()
          .map((e) => ExperienceModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Crea una experiencia. Si [certificateFile] viene informado, primero se
  /// sube con [UploadService] (regla de negocio #9: servicio compartido) y
  /// luego se envía la URL resultante como `certificateUrl`.
  Future<ExperienceModel> addExperience({
    required String title,
    String? company,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    File? certificateFile,
  }) async {
    try {
      String? certificateUrl;
      if (certificateFile != null) {
        certificateUrl = await _uploadService.uploadImage(certificateFile);
      }

      final response = await _dio.post(
        '/me/experiences',
        data: {
          'title': title,
          if (company != null) 'company': company,
          if (description != null) 'description': description,
          if (startDate != null) 'startDate': startDate.toIso8601String(),
          if (endDate != null) 'endDate': endDate.toIso8601String(),
          if (certificateUrl != null) 'certificateUrl': certificateUrl,
        },
      );
      final data = _unwrapData(response.data);
      if (data is! Map) {
        throw ApiException('La experiencia creada no tiene un formato válido.');
      }
      return ExperienceModel.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  dynamic _unwrapData(dynamic responseData) {
    if (responseData is Map && responseData['data'] != null) {
      return responseData['data'];
    }
    return responseData;
  }

  Future<void> deleteExperience(String experienceId) async {
    try {
      await _dio.delete('/me/experiences/$experienceId');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // ---------------------------------------------------------------------
  // Aplicar a una oferta (embebido por P2 en offer_detail_screen.dart)
  // ---------------------------------------------------------------------

  Future<ApplicationModel> applyToOffer({
    required String offerId,
    required String comment,
    List<DynamicFieldAnswer> answers = const [],
  }) async {
    try {
      final response = await _dio.post(
        '/offers/$offerId/apply',
        data: {
          'comment': comment,
          'answers': answers.map((a) => a.toJson()).toList(),
        },
      );
      return ApplicationModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // ---------------------------------------------------------------------
  // Mis aplicaciones
  // ---------------------------------------------------------------------

  Future<List<ApplicationModel>> getMyApplications() async {
    try {
      final response = await _dio.get('/me/applications');
      final data = response.data;
      final list = data is List
          ? data
          : (data['data'] ?? data['applications'] ?? []);
      return List<ApplicationModel>.from(
        list.map((a) => ApplicationModel.fromJson(a)),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // ---------------------------------------------------------------------
  // Aplicantes de una oferta que publiqué (solo dueño de la oferta)
  // ---------------------------------------------------------------------

  Future<List<ApplicationModel>> getApplicantsForOffer(String offerId) async {
    try {
      final response = await _dio.get('/offers/$offerId/applications');
      final data = response.data;
      final list = data is List
          ? data
          : (data['data'] ?? data['applications'] ?? []);
      return List<ApplicationModel>.from(
        list.map((a) => ApplicationModel.fromJson(a)),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Califica una aplicación con una puntuación (por ejemplo 1–5).
  Future<ApplicationModel> rateApplication(String applicationId, int rating) {
    return _patchApplication(applicationId, {'rating': rating});
  }

  /// Descarta una aplicación.
  Future<ApplicationModel> discardApplication(String applicationId) {
    return _patchApplication(applicationId, {'status': 'discarded'});
  }

  /// Marca una aplicación como finalista.
  Future<ApplicationModel> markAsFinalist(String applicationId) {
    return _patchApplication(applicationId, {'status': 'finalist'});
  }

  /// Marca una aplicación como ganadora.
  ///
  /// Regla de negocio #8: al hacer esto, el API crea el contrato
  /// automáticamente. La respuesta puede incluir `contractId`; la pantalla
  /// que llama a este método es responsable de navegar al contrato
  /// (módulo de Persona 4) si ese campo viene presente.
  Future<ApplicationModel> markAsWinner(String applicationId) {
    return _patchApplication(applicationId, {'status': 'winner'});
  }

  Future<ApplicationModel> _patchApplication(
    String applicationId,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.patch(
        '/applications/$applicationId',
        data: body,
      );
      return ApplicationModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // ---------------------------------------------------------------------
  // Me gusta
  // ---------------------------------------------------------------------

  Future<void> likeOffer(String offerId) async {
    try {
      await _dio.post('/offers/$offerId/like');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> unlikeOffer(String offerId) async {
    try {
      await _dio.delete('/offers/$offerId/like');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<LikedOfferModel>> getMyLikedOffers() async {
    try {
      final response = await _dio.get('/me/likes');
      final data = response.data;
      final list = data is List ? data : (data['data'] ?? data['offers'] ?? []);
      return List<LikedOfferModel>.from(
        list.map((o) => LikedOfferModel.fromJson(o)),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
