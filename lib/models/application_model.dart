/// Modelo de una aplicación a una oferta. Dueño: Persona 3.
///
/// Cubre la respuesta de:
///  - GET /me/applications          (mis aplicaciones)
///  - GET /offers/{id}/applications (aplicantes de una oferta que publiqué)
///  - POST /offers/{id}/apply       (respuesta al aplicar)
///
/// ⚠️ Verifica los nombres exactos de campo contra el Swagger
/// (https://ocupa2.ia3x.com/apix/docs) y ajusta el `fromJson` si difieren —
/// aquí se cubren varios alias comunes (camelCase/snake_case) para reducir
/// el riesgo de romper si el backend usa una convención distinta.
enum ApplicationStatus { pending, discarded, finalist, winner, unknown }

ApplicationStatus applicationStatusFromString(String? raw) {
  switch (raw) {
    case 'pending':
    case 'reviewing':
    case 'en_revision':
    case 'en_revisión':
      return ApplicationStatus.pending;
    case 'discarded':
    case 'descartado':
      return ApplicationStatus.discarded;
    case 'finalist':
    case 'finalista':
      return ApplicationStatus.finalist;
    case 'winner':
    case 'ganador':
      return ApplicationStatus.winner;
    default:
      return ApplicationStatus.unknown;
  }
}

extension ApplicationStatusLabel on ApplicationStatus {
  String get label {
    switch (this) {
      case ApplicationStatus.pending:
        return 'En revisión';
      case ApplicationStatus.discarded:
        return 'Descartado';
      case ApplicationStatus.finalist:
        return 'Finalista';
      case ApplicationStatus.winner:
        return 'Ganador';
      case ApplicationStatus.unknown:
        return 'Desconocido';
    }
  }
}

class ApplicationAnswerModel {
  final String questionId;
  final String? questionLabel;
  final dynamic value;

  ApplicationAnswerModel({
    required this.questionId,
    this.questionLabel,
    this.value,
  });

  factory ApplicationAnswerModel.fromJson(Map<String, dynamic> json) {
    return ApplicationAnswerModel(
      questionId: (json['questionId'] ?? json['id'] ?? '').toString(),
      questionLabel: json['questionLabel'] ?? json['label'],
      value: json['value'],
    );
  }
}

class ApplicationModel {
  final String id;
  final String offerId;
  final String? contractId;
  final String? offerTitle;
  final String? applicantId;
  final String? applicantName;
  final String comment;
  final List<ApplicationAnswerModel> answers;
  final ApplicationStatus status;
  final int? rating;
  final DateTime? createdAt;

  ApplicationModel({
    required this.id,
    required this.offerId,
    this.contractId,
    this.offerTitle,
    this.applicantId,
    this.applicantName,
    required this.comment,
    this.answers = const [],
    required this.status,
    this.rating,
    this.createdAt,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: (json['id'] ?? '').toString(),
      offerId: (json['offerId'] ?? json['offer_id'] ?? '').toString(),
      contractId: (json['contractId'] ?? json['contract_id'] ?? json['contract']?['id'])?.toString(),
      offerTitle: json['offerTitle'] ?? json['offer']?['title'],
      applicantId: json['applicantId']?.toString(),
      applicantName: json['applicantName'] ?? json['applicant']?['name'],
      comment: (json['comment'] ?? '').toString(),
      answers: json['answers'] is List
          ? List<ApplicationAnswerModel>.from(
              json['answers'].map((a) => ApplicationAnswerModel.fromJson(a)))
          : const [],
      status: applicationStatusFromString(json['status']?.toString()),
      rating: json['rating'] is int ? json['rating'] as int : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}
