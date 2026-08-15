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
    );
  }
}