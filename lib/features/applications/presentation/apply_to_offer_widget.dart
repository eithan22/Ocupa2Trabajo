import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/dynamic_field_model.dart';
import '../providers/applications_provider.dart';
import 'widgets/dynamic_answer_field.dart';

/// Widget independiente de Persona 3 que Persona 2 embebe al final de
/// `offer_detail_screen.dart` (Punto de integración #4 del README).
///
/// Contrato acordado en el README:
///   - recibe `offerId`
///   - expone `onApplied()`
///
/// Además recibe `questions` (las preguntas adicionales de la oferta, tipo
/// `text/date/select/check`) porque ese dato vive en el `OfferModel` que ya
/// tiene P2 cargado en su pantalla — así este widget no necesita volver a
/// pedir el detalle de la oferta, solo el envío del POST /offers/{id}/apply.
///
/// Uso típico desde offer_detail_screen.dart (P2):
/// ```dart
/// ApplyToOfferWidget(
///   offerId: offer.id,
///   questions: offer.questions, // List<DynamicFieldModel>
///   onApplied: () => ScaffoldMessenger.of(context).showSnackBar(
///     const SnackBar(content: Text('¡Aplicación enviada!')),
///   ),
/// )
/// ```
class ApplyToOfferWidget extends StatefulWidget {
  final String offerId;
  final List<DynamicFieldModel> questions;
  final VoidCallback? onApplied;

  const ApplyToOfferWidget({
    super.key,
    required this.offerId,
    this.questions = const [],
    this.onApplied,
  });

  @override
  State<ApplyToOfferWidget> createState() => _ApplyToOfferWidgetState();
}

class _ApplyToOfferWidgetState extends State<ApplyToOfferWidget> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  final Map<String, dynamic> _answerValues = {};
  bool _submitted = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ApplicationsProvider>();
    final answers = widget.questions
        .where((q) => _answerValues.containsKey(q.id))
        .map((q) => DynamicFieldAnswer(fieldId: q.id, value: _answerValues[q.id]))
        .toList();

    final success = await provider.applyToOffer(
      offerId: widget.offerId,
      comment: _commentController.text.trim(),
      answers: answers,
    );

    if (!mounted) return;

    if (success) {
      setState(() => _submitted = true);
      widget.onApplied?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Tu aplicación fue enviada!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.applyError ?? 'No se pudo enviar tu aplicación.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ApplicationsProvider>();

    if (_submitted) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Expanded(child: Text('Ya aplicaste a esta oferta.')),
          ],
        ),
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Text('Aplicar a esta oferta', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextFormField(
            controller: _commentController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Comentario para el contratante',
              border: OutlineInputBorder(),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Escribe un breve comentario' : null,
          ),
          if (widget.questions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Preguntas adicionales', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            for (final question in widget.questions) ...[
              DynamicAnswerField(
                field: question,
                onChanged: (value) => _answerValues[question.id] = value,
              ),
              const SizedBox(height: 12),
            ],
          ],
          const SizedBox(height: 8),
          FilledButton(
            onPressed: provider.isApplying ? null : _submit,
            child: provider.isApplying
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Enviar aplicación'),
          ),
        ],
      ),
    );
  }
}
