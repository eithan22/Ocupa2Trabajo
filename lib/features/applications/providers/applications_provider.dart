import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/api_exception.dart';
import '../../../models/application_model.dart';
import '../../../models/dynamic_field_model.dart';
import '../../../models/experience_model.dart';
import '../data/applications_repository.dart';

enum LoadStatus { idle, loading, success, error }

/// Estado del módulo "Aplicaciones y Experiencias".
///
/// Un solo provider para aplicaciones y experiencias porque comparten el
/// mismo repositorio y así evitamos providers adicionales al embeber
/// `ApplyToOfferWidget`.
class ApplicationsProvider extends ChangeNotifier {
  final ApplicationsRepository _repository;

  ApplicationsProvider({ApplicationsRepository? repository})
    : _repository = repository ?? ApplicationsRepository();

  // --- Mis aplicaciones ---
  LoadStatus myApplicationsStatus = LoadStatus.idle;
  List<ApplicationModel> myApplications = [];
  String? myApplicationsError;

  // --- Aplicantes de una oferta (vista del dueño de la oferta) ---
  LoadStatus applicantsStatus = LoadStatus.idle;
  List<ApplicationModel> applicants = [];
  String? applicantsError;

  // --- Experiencias ---
  LoadStatus experiencesStatus = LoadStatus.idle;
  List<ExperienceModel> experiences = [];
  String? experiencesError;

  // --- Aplicar a una oferta ---
  bool isApplying = false;
  String? applyError;

  // ---------------------------------------------------------------------
  // Mis aplicaciones
  // ---------------------------------------------------------------------

  Future<void> loadMyApplications() async {
    myApplicationsStatus = LoadStatus.loading;
    myApplicationsError = null;
    notifyListeners();
    try {
      myApplications = await _repository.getMyApplications();
      myApplicationsStatus = LoadStatus.success;
    } catch (e) {
      myApplicationsStatus = LoadStatus.error;
      myApplicationsError = e is ApiException
          ? e.message
          : 'Error al cargar tus aplicaciones.';
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Aplicar a una oferta — usado por ApplyToOfferWidget
  // ---------------------------------------------------------------------

  Future<bool> applyToOffer({
    required String offerId,
    required String comment,
    List<DynamicFieldAnswer> answers = const [],
  }) async {
    isApplying = true;
    applyError = null;
    notifyListeners();
    try {
      await _repository.applyToOffer(
        offerId: offerId,
        comment: comment,
        answers: answers,
      );
      isApplying = false;
      notifyListeners();
      return true;
    } catch (e) {
      isApplying = false;
      applyError = e is ApiException
          ? e.message
          : 'No se pudo enviar tu aplicación.';
      notifyListeners();
      return false;
    }
  }

  // ---------------------------------------------------------------------
  // Aplicantes de una oferta (gestión: calificar / descartar / ganador)
  // ---------------------------------------------------------------------

  Future<void> loadApplicantsForOffer(String offerId) async {
    applicantsStatus = LoadStatus.loading;
    applicantsError = null;
    notifyListeners();
    try {
      applicants = await _repository.getApplicantsForOffer(offerId);
      applicantsStatus = LoadStatus.success;
    } catch (e) {
      applicantsStatus = LoadStatus.error;
      applicantsError = e is ApiException
          ? e.message
          : 'Error al cargar los aplicantes.';
    }
    notifyListeners();
  }

  Future<bool> rateApplicant(String applicationId, int rating) async {
    return _updateApplicantLocally(
      applicationId,
      () => _repository.rateApplication(applicationId, rating),
    );
  }

  Future<bool> discardApplicant(String applicationId) async {
    return _updateApplicantLocally(
      applicationId,
      () => _repository.discardApplication(applicationId),
    );
  }

  Future<bool> markApplicantAsFinalist(String applicationId) async {
    return _updateApplicantLocally(
      applicationId,
      () => _repository.markAsFinalist(applicationId),
    );
  }

  /// Marca un aplicante como ganador. El API crea el contrato
  /// automáticamente (regla de negocio #8); esta capa solo actualiza el
  /// estado local, la pantalla se encarga de navegar al contrato.
  Future<bool> chooseWinner(String applicationId) async {
    return _updateApplicantLocally(
      applicationId,
      () => _repository.markAsWinner(applicationId),
    );
  }

  Future<bool> _updateApplicantLocally(
    String applicationId,
    Future<ApplicationModel> Function() action,
  ) async {
    try {
      final updated = await action();
      final index = applicants.indexWhere((a) => a.id == applicationId);
      if (index != -1) {
        applicants = List.of(applicants)..[index] = updated;
      }
      notifyListeners();
      return true;
    } catch (e) {
      applicantsError = e is ApiException
          ? e.message
          : 'No se pudo actualizar el aplicante.';
      notifyListeners();
      return false;
    }
  }

  // ---------------------------------------------------------------------
  // Experiencias
  // ---------------------------------------------------------------------

  Future<void> loadMyExperiences() async {
    experiencesStatus = LoadStatus.loading;
    experiencesError = null;
    notifyListeners();
    try {
      experiences = await _repository.getMyExperiences();
      experiencesStatus = LoadStatus.success;
    } catch (e) {
      experiencesStatus = LoadStatus.error;
      experiencesError = e is ApiException
          ? e.message
          : 'Error al cargar tus experiencias.';
    }
    notifyListeners();
  }

  Future<bool> addExperience({
    required String title,
    String? company,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    XFile? certificateFile,
  }) async {
    try {
      final created = await _repository.addExperience(
        title: title,
        company: company,
        description: description,
        startDate: startDate,
        endDate: endDate,
        certificateFile: certificateFile,
      );
      experiences = [created, ...experiences];
      notifyListeners();
      return true;
    } catch (e) {
      experiencesError = e is ApiException
          ? e.message
          : 'No se pudo agregar la experiencia.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteExperience(String experienceId) async {
    try {
      await _repository.deleteExperience(experienceId);
      experiences = experiences.where((exp) => exp.id != experienceId).toList();
      notifyListeners();
      return true;
    } catch (e) {
      experiencesError = e is ApiException
          ? e.message
          : 'No se pudo eliminar la experiencia.';
      notifyListeners();
      return false;
    }
  }
}
