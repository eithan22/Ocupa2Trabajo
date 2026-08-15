import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/job_type_model.dart';

class DynamicFormField extends StatelessWidget {
  final CustomFieldModel fieldConfig;
  final dynamic initialValue;
  final void Function(dynamic value) onChanged;

  const DynamicFormField({
    super.key,
    required this.fieldConfig,
    required this.onChanged,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRequiredLabel = fieldConfig.isRequired ? ' *' : '';

    switch (fieldConfig.type.toLowerCase()) {
      case 'select':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: DropdownButtonFormField<String>(
            value: initialValue,
            decoration: InputDecoration(
              labelText: '${fieldConfig.label}$isRequiredLabel',
              border: const OutlineInputBorder(),
            ),
            items: fieldConfig.options?.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList() ?? [],
            onChanged: (val) => onChanged(val),
            validator: fieldConfig.isRequired
                ? (value) => value == null || value.isEmpty ? 'Requerido' : null
                : null,
          ),
        );

      case 'check':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: CheckboxListTile(
            title: Text('${fieldConfig.label}$isRequiredLabel'),
            value: initialValue == true || initialValue == 'true',
            onChanged: (val) => onChanged(val),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
        );

      case 'date':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: TextFormField(
            readOnly: true,
            controller: TextEditingController(
              text: initialValue != null
                  ? DateFormat('yyyy-MM-dd').format(DateTime.parse(initialValue))
                  : '',
            ),
            decoration: InputDecoration(
              labelText: '${fieldConfig.label}$isRequiredLabel',
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                onChanged(date.toIso8601String());
              }
            },
            validator: fieldConfig.isRequired
                ? (value) => value == null || value.isEmpty ? 'Requerido' : null
                : null,
          ),
        );

      case 'text':
      default:
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: TextFormField(
            initialValue: initialValue?.toString(),
            decoration: InputDecoration(
              labelText: '${fieldConfig.label}$isRequiredLabel',
              border: const OutlineInputBorder(),
            ),
            onChanged: onChanged,
            validator: fieldConfig.isRequired
                ? (value) => value == null || value.trim().isEmpty ? 'Requerido' : null
                : null,
          ),
        );
    }
  }
}