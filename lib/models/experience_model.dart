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
      id: (json['id'] ?? json['experienceId'] ?? '').toString(),
      title:
          (json['title'] ??
                  json['position'] ??
                  json['jobTitle'] ??
                  json['job_title'] ??
                  '')
              .toString(),
      company: _asNullableString(
        json['company'] ??
            json['institution'] ??
            json['companyName'] ??
            json['company_name'],
      ),
      description: _asNullableString(json['description'] ?? json['details']),
      startDate: _parseDate(
        json['startDate'] ?? json['start_date'] ?? json['from'],
      ),
      endDate: _parseDate(json['endDate'] ?? json['end_date'] ?? json['to']),
      certificateUrl: _asNullableString(
        json['certificateUrl'] ??
            json['certificate_url'] ??
            json['imageUrl'] ??
            json['image_url'] ??
            json['image'],
      ),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    return value != null ? DateTime.tryParse(value.toString()) : null;
  }

  static String? _asNullableString(dynamic value) {
    if (value == null) return null;
    final result = value.toString().trim();
    return result.isEmpty ? null : result;
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
