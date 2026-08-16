import 'dynamic_field_model.dart';

class OfferModel {
  final String id;
  final String title;
  final String description;
  final String jobTypeKey;
  final String contractType;
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
    this.latitude,
    this.longitude,
    this.imageUrl,
    required this.status,
    this.contratante,
    this.questions = const [],
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      jobTypeKey: json['jobTypeKey'] ?? '',
      contractType: json['contractType'] ?? 'temporal',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      imageUrl: json['imageUrl'],
      status: json['status'] ?? 'active',
      contratante: json['contratante'],
      questions: ((json['questions'] ?? json['customQuestions']) as List<dynamic>?)
              ?.map((item) => DynamicFieldModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
