import 'dynamic_field_model.dart';

class OfferModel {
  final String id;
  final String title;
  final String description;
  final String jobTypeKey;
  final String contractType;
  final double? salary;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final String status;
  final String? contratante;
  final List<DynamicFieldModel> questions;

  OfferModel({
    required this.id,
    required this.title,
    required this.description,
    required this.jobTypeKey,
    required this.contractType,
    this.salary,
    this.latitude,
    this.longitude,
    this.imageUrl,
    required this.status,
    this.contratante,
    this.questions = const [],
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] is Map
        ? Map<String, dynamic>.from(json['location'] as Map)
        : const <String, dynamic>{};

    return OfferModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      jobTypeKey: json['jobTypeKey'] ?? '',
      contractType: json['contractType'] ?? 'temporal',
      salary: _toDouble(
        json['salary'] ??
            json['paymentAmount'] ??
            json['amount'] ??
            (json['payment'] is Map ? json['payment']['amount'] : null),
      ),
      latitude: _toDouble(json['latitude'] ?? json['lat'] ?? location['lat']),
      longitude: _toDouble(json['longitude'] ?? json['lng'] ?? location['lng']),
      imageUrl: json['imageUrl'] ?? json['photoUrl'] ?? json['photo'],
      status: json['status'] ?? 'active',
      contratante: json['contratante'],
      questions:
          ((json['questions'] ?? json['customQuestions']) as List<dynamic>?)
              ?.map(
                (item) =>
                    DynamicFieldModel.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}
