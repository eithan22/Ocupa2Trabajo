/// Modelo genérico para campos dinámicos.
///
/// El README (Punto de integración #3) aclara que `CustomField` (tipos de
/// empleo, dominio de Persona 2) y `Question` (preguntas adicionales de una
/// oferta, dominio de Persona 3 al aplicar) comparten exactamente los mismos
/// tipos: `text`, `date`, `select`, `check`. Por eso este modelo vive en
/// `lib/models/` como algo compartido, y tanto `dynamic_form_field.dart`
/// (P2) como el formulario de aplicación (P3, este módulo) deberían
/// renderizar a partir de él.
///
/// ⚠️ Si Persona 2 ya publicó su propio `CustomFieldModel` con otro nombre de
/// campos, avísense en el equipo y unifiquen en esta clase (o renombren esta
/// para calzar con la suya) — no deben mantener dos modelos paralelos para
/// lo mismo, según la regla de los 2 en `core/widgets/`.
enum DynamicFieldType { text, date, select, check, unknown }

DynamicFieldType dynamicFieldTypeFromString(String? raw) {
  switch (raw) {
    case 'text':
      return DynamicFieldType.text;
    case 'date':
      return DynamicFieldType.date;
    case 'select':
      return DynamicFieldType.select;
    case 'check':
      return DynamicFieldType.check;
    default:
      return DynamicFieldType.unknown;
  }
}

class DynamicFieldModel {
  final String id;
  final String label;
  final DynamicFieldType type;
  final List<String> options; // usado cuando type == select
  final bool required;

  DynamicFieldModel({
    required this.id,
    required this.label,
    required this.type,
    this.options = const [],
    this.required = false,
  });

  factory DynamicFieldModel.fromJson(Map<String, dynamic> json) {
    return DynamicFieldModel(
      id: (json['id'] ?? json['key'] ?? '').toString(),
      label: (json['label'] ?? json['question'] ?? json['name'] ?? '').toString(),
      type: dynamicFieldTypeFromString(json['type']?.toString()),
      options: json['options'] is List
          ? List<String>.from(json['options'].map((o) => o.toString()))
          : const [],
      required: json['required'] == true,
    );
  }
}

/// Una respuesta concreta del aplicante a un [DynamicFieldModel].
class DynamicFieldAnswer {
  final String fieldId;
  final dynamic value; // String, bool o fecha en formato ISO, según el tipo

  DynamicFieldAnswer({required this.fieldId, required this.value});

  Map<String, dynamic> toJson() => {
        'questionId': fieldId,
        'value': value,
      };
}
