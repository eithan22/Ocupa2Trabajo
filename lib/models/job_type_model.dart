class JobTypeModel {
  final String key;
  final String name;
  final String description;
  final List<CustomFieldModel> customFields;

  JobTypeModel({
    required this.key,
    required this.name,
    required this.description,
    this.customFields = const [],
  });

  factory JobTypeModel.fromJson(Map<String, dynamic> json) {
    return JobTypeModel(
      key: json['key'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      customFields: (json['customFields'] as List<dynamic>?)
          ?.map((e) => CustomFieldModel.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class CustomFieldModel {
  final String name;
  final String label;
  final String type; 
  final bool isRequired;
  final List<String>? options;

  CustomFieldModel({
    required this.name,
    required this.label,
    required this.type,
    this.isRequired = false,
    this.options,
  });

  factory CustomFieldModel.fromJson(Map<String, dynamic> json) {
    return CustomFieldModel(
      name: json['name'] ?? '',
      label: json['label'] ?? json['name'] ?? '',
      type: json['type'] ?? 'text',
      isRequired: json['isRequired'] ?? false,
      options: (json['options'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
    );
  }
}