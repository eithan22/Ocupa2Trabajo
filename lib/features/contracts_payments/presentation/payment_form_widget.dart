import 'package:flutter/material.dart';

import '../../../core/widgets/inline_error_banner.dart';
import '../providers/payments_provider.dart';

/// Formulario reutilizable para el cobro de publicación de una oferta.
/// Devuelve el id aprobado mediante [onPaymentApproved].
class PaymentFormWidget extends StatefulWidget {
  const PaymentFormWidget({super.key, required this.onPaymentApproved});

  final ValueChanged<String> onPaymentApproved;

  @override
  State<PaymentFormWidget> createState() => _PaymentFormWidgetState();
}

class _PaymentFormWidgetState extends State<PaymentFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cvvController = TextEditingController();
  final _monthController = TextEditingController();
  final _yearController = TextEditingController();
  final _cardholderController = TextEditingController();
  final PaymentsProvider _provider = PaymentsProvider();

  String? _approvedPaymentId;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cvvController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    _cardholderController.dispose();
    _provider.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final payment = await _provider.createPayment(
      cardNumber: _cardNumberController.text.replaceAll(' ', ''),
      cvv: _cvvController.text.trim(),
      expMonth: int.parse(_monthController.text.trim()),
      expYear: int.parse(_yearController.text.trim()),
      cardholder: _cardholderController.text,
    );

    if (!mounted || payment == null) return;
    setState(() => _approvedPaymentId = payment.id);
    widget.onPaymentApproved(payment.id);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _provider,
      builder: (context, _) {
        if (_approvedPaymentId != null) {
          return Card(
            color: colorScheme.primaryContainer,
            child: ListTile(
              leading: Icon(
                Icons.check_circle,
                color: colorScheme.onPrimaryContainer,
              ),
              title: const Text('Pago aprobado'),
              subtitle: Text('ID de pago: $_approvedPaymentId'),
            ),
          );
        }

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_provider.errorMessage != null)
                InlineErrorBanner(message: _provider.errorMessage!),
              Text(
                'Pago de publicación: 1 USD',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Número de tarjeta',
                  hintText: '4242 4242 4242 4242',
                  prefixIcon: Icon(Icons.credit_card),
                ),
                validator: (value) {
                  final digits = value?.replaceAll(' ', '') ?? '';
                  return digits.length < 12
                      ? 'Escribe un número de tarjeta válido'
                      : null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'CVV'),
                      validator: (value) => (value?.trim().length ?? 0) < 3
                          ? 'CVV inválido'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _monthController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Mes'),
                      validator: (value) {
                        final month = int.tryParse(value?.trim() ?? '');
                        return month == null || month < 1 || month > 12
                            ? 'Mes inválido'
                            : null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _yearController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Año'),
                      validator: (value) =>
                          int.tryParse(value?.trim() ?? '') == null
                          ? 'Año inválido'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cardholderController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Titular (opcional)',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Prueba aprobada: 4242 4242 4242 4242. Prueba rechazada: 4000 0000 0000 0002.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _provider.isLoading ? null : _submit,
                icon: _provider.isLoading
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.lock_outline),
                label: Text(
                  _provider.isLoading ? 'Procesando…' : 'Pagar 1 USD',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
