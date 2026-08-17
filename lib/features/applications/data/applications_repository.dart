import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/services/upload_service.dart';
import '../../../models/application_model.dart';
import '../../../models/dynamic_field_model.dart';
import '../../../models/experience_model.dart';

/// Capa de datos del módulo "Aplicaciones y Experiencias" (Persona 3).
///
/// Agrupa TODOS los endpoints listados en el README para este módulo:
///  - /me/experiences        (GET, POST, DELETE)
///  - /offers/{id}/apply     (POST)
///  - /offers/{id}/applications (GET)
///  - /me/applications       (GET)
///  - /applications/{id}     (PATCH)
class ApplicationsRepository {
  final Dio _dio = DioClient.instance.dio;
  final UploadService _uploadService = UploadService();

  // ---------------------------------------------------------------------
  // Experiencias (Mi perfil / experiencias)
  // ---------------------------------------------------------------------

  Future<List<ExperienceModel>> getMyExperiences() async {
    try {
      final response = await _dio.get('/me/experiences');
      final list = _extractList(response.data);
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
    XFile? certificateFile,
  }) async {
    try {
      String? certificateUrl;
      if (certificateFile != null) {
        certificateUrl = await _uploadService.uploadImageBytes(
          bytes: await certificateFile.readAsBytes(),
          filename: certificateFile.name,
        );
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
    var current = responseData;
    while (current is Map && current['data'] != null) {
      current = current['data'];
    }
    if (current is Map && current['experience'] != null) {
      return current['experience'];
    }
    return current;
  }

  List<dynamic> _extractList(dynamic responseData) {
    var current = responseData;
    while (current is Map) {
      if (current['data'] != null) {
        current = current['data'];
        continue;
      }
      if (current['experiences'] != null) {
        current = current['experiences'];
        continue;
      }
      if (current['items'] != null) {
        current = current['items'];
        continue;
      }
      if (current['results'] != null) {
        current = current['results'];
        continue;
      }
      break;
    }
    return current is List ? current : const <dynamic>[];
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
}
