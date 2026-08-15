import 'package:flutter/material.dart';

import '../../../../models/dynamic_field_model.dart';

/// Renderiza UN campo de pregunta dinámica (text/date/select/check) y
/// reporta su valor actual vía [onChanged].
///
/// ⚠️ Nota de integración (ver README, punto #3): esta es la versión de
/// Persona 3 del mismo patrón que usará `dynamic_form_field.dart` de
/// Persona 2 para `CustomField`. Cuando P2 publique el suyo, lo ideal es
/// unificar ambos en `core/widgets/dynamic_form_field.dart` (regla de los 2:
/// se mueve a core/widgets solo cuando una segunda persona lo necesita
/// exactamente igual — este es justo ese caso). Mientras tanto, este widget
/// vive dentro de `features/applications/` para no bloquear a nadie.
class DynamicAnswerField extends StatefulWidget {
  final DynamicFieldModel field;
  final ValueChanged<dynamic> onChanged;

  const DynamicAnswerField({
    super.key,
    required this.field,
    required this.onChanged,
  });

  @override
  State<DynamicAnswerField> createState() => _DynamicAnswerFieldState();
}

class _DynamicAnswerFieldState extends State<DynamicAnswerField> {
  final _textController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedOption;
  bool _checked = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  String get _label => widget.field.required ? '${widget.field.label} *' : widget.field.label;

  @override
  Widget build(BuildContext context) {
    switch (widget.field.type) {
      case DynamicFieldType.text:
        return TextFormField(
          controller: _textController,
          decoration: InputDecoration(labelText: _label, border: const OutlineInputBorder()),
          onChanged: widget.onChanged,
          validator: widget.field.required
              ? (v) => (v == null || v.trim().isEmpty) ? 'Este campo es obligatorio' : null
              : null,
        );

      case DynamicFieldType.date:
        return InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime.now(),
              firstDate: DateTime(1970),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setState(() => _selectedDate = picked);
              widget.onChanged(picked.toIso8601String());
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(labelText: _label, border: const OutlineInputBorder()),
            child: Text(
              _selectedDate != null
                  ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                  : 'Selecciona una fecha',
            ),
          ),
        );

      case DynamicFieldType.select:
        return DropdownButtonFormField<String>(
          value: _selectedOption,
          decoration: InputDecoration(labelText: _label, border: const OutlineInputBorder()),
          items: widget.field.options
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged: (value) {
            setState(() => _selectedOption = value);
            widget.onChanged(value);
          },
          validator: widget.field.required
              ? (v) => v == null ? 'Selecciona una opción' : null
              : null,
        );

      case DynamicFieldType.check:
        return CheckboxListTile(
          title: Text(_label),
          value: _checked,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          onChanged: (value) {
            setState(() => _checked = value ?? false);
            widget.onChanged(value ?? false);
          },
        );

      case DynamicFieldType.unknown:
        return const SizedBox.shrink();
    }
  }
}
