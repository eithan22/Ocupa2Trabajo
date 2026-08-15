/// Modelo de una experiencia laboral / certificado del perfil del usuario.
/// Dueño: Persona 3. Cubre GET/POST/DELETE /me/experiences.
///
/// ⚠️ Igual que ApplicationModel, confirma nombres de campo contra el
/// Swagger y ajusta si es necesario.
class ExperienceModel {
  final String id;
  final String title;
  final String? company;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? certificateUrl;

  ExperienceModel({
    required this.id,
    required this.title,
    this.company,
    this.description,
    this.startDate,
    this.endDate,
    this.certificateUrl,
  });

  bool get isOngoing => endDate == null;

  factory ExperienceModel.fromJson(Map<String, dynamic> json) {
    return ExperienceModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? json['position'] ?? '').toString(),
      company: json['company'] ?? json['institution'],
      description: json['description'],
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString())
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString())
          : null,
      certificateUrl: json['certificateUrl'] ?? json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        if (company != null) 'company': company,
        if (description != null) 'description': description,
        if (startDate != null) 'startDate': startDate!.toIso8601String(),
        if (endDate != null) 'endDate': endDate!.toIso8601String(),
        if (certificateUrl != null) 'certificateUrl': certificateUrl,
      };
}
