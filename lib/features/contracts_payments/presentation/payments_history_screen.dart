import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../models/payment_model.dart';
import '../providers/payments_provider.dart';

class PaymentsHistoryScreen extends StatefulWidget {
  const PaymentsHistoryScreen({super.key});

  @override
  State<PaymentsHistoryScreen> createState() => _PaymentsHistoryScreenState();
}

class _PaymentsHistoryScreenState extends State<PaymentsHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentsProvider>().loadPayments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PaymentsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mis pagos')),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(PaymentsProvider provider) {
    if (provider.isLoading && provider.payments.isEmpty) {
      return const LoadingView(message: 'Cargando historial…');
    }
    if (provider.errorMessage != null && provider.payments.isEmpty) {
      return ErrorView(
        message: provider.errorMessage!,
        onRetry: provider.loadPayments,
      );
    }
    if (provider.payments.isEmpty) {
      return RefreshIndicator(
        onRefresh: provider.loadPayments,
        child: ListView(
          children: const [
            SizedBox(height: 180),
            Center(child: Text('Aún no tienes pagos registrados.')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.loadPayments,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: provider.payments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) =>
            _PaymentTile(payment: provider.payments[index]),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({required this.payment});

  final PaymentModel payment;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final approved =
        payment.status == 'approved' || payment.status == 'succeeded';

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: approved
              ? scheme.primaryContainer
              : scheme.errorContainer,
          child: Icon(
            approved ? Icons.check : Icons.credit_card,
            color: approved
                ? scheme.onPrimaryContainer
                : scheme.onErrorContainer,
          ),
        ),
        title: Text('${payment.amount.toStringAsFixed(2)} ${payment.currency}'),
        subtitle: Text(
          [
            'Estado: ${_statusLabel(payment.status)}',
            if (payment.cardLast4 != null)
              'Tarjeta terminada en ${payment.cardLast4}',
            if (payment.createdAt != null) _formatDate(payment.createdAt!),
          ].join(' · '),
        ),
      ),
    );
  }

  static String _statusLabel(String status) {
    switch (status) {
      case 'approved':
      case 'succeeded':
        return 'Aprobado';
      case 'rejected':
        return 'Rechazado';
      default:
        return status;
    }
  }

  static String _formatDate(DateTime value) {
    final date = value.toLocal();
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
