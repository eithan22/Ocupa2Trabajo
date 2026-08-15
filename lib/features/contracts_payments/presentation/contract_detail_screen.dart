import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../models/contract_model.dart';
import '../providers/contracts_provider.dart';
import '../services/contract_photo_uploader.dart';

class ContractDetailScreen extends StatefulWidget {
  const ContractDetailScreen({super.key, required this.contractId});

  final String contractId;

  @override
  State<ContractDetailScreen> createState() => _ContractDetailScreenState();
}

class _ContractDetailScreenState extends State<ContractDetailScreen> {
  final _commentController = TextEditingController();
  bool _uploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContractsProvider>().loadContract(widget.contractId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ContractsProvider>();
    final contract = provider.currentContract;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del contrato')),
      body: provider.isLoading && contract == null
          ? const LoadingView(message: 'Cargando contrato…')
          : provider.errorMessage != null && contract == null
          ? ErrorView(
              message: provider.errorMessage!,
              onRetry: () => provider.loadContract(widget.contractId),
            )
          : contract == null
          ? const Center(child: Text('No se encontró el contrato.'))
          : _buildContent(context, provider, contract),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ContractsProvider provider,
    ContractModel contract,
  ) {
    final error = provider.errorMessage;

    return RefreshIndicator(
      onRefresh: () => provider.loadContract(widget.contractId),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (error != null) _ErrorBanner(message: error),
          _SummaryCard(contract: contract),
          const SizedBox(height: 16),
          _TermsCard(contract: contract),
          const SizedBox(height: 16),
          _buildActions(context, provider, contract),
          if (contract.comments.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Comentarios', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ...contract.comments.map(
              (comment) => _CommentTile(comment: comment),
            ),
          ],
          if (contract.photos.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Fotos del contrato',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ...contract.photos.map((photo) => _PhotoTile(photo: photo)),
          ],
          if (contract.isActive) ...[
            const SizedBox(height: 20),
            _CommentComposer(
              controller: _commentController,
              enabled: !provider.isLoading,
              onSend: () => _addComment(provider, contract.id),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActions(
    BuildContext context,
    ContractsProvider provider,
    ContractModel contract,
  ) {
    final actions = <Widget>[];

    if (contract.isPending && contract.myRole == 'contratante') {
      actions.add(
        FilledButton.icon(
          onPressed: provider.isLoading
              ? null
              : () => _showTermsDialog(provider, contract),
          icon: const Icon(Icons.edit_note),
          label: Text(
            contract.salary == null ? 'Fijar términos' : 'Editar términos',
          ),
        ),
      );
    }

    if (contract.isPending && contract.myRole == 'contratado') {
      actions.addAll([
        FilledButton.icon(
          onPressed: provider.isLoading
              ? null
              : () => _confirmDecision(provider, contract, accept: true),
          icon: const Icon(Icons.check),
          label: const Text('Aceptar contrato'),
        ),
        OutlinedButton.icon(
          onPressed: provider.isLoading
              ? null
              : () => _confirmDecision(provider, contract, accept: false),
          icon: const Icon(Icons.close),
          label: const Text('Rechazar'),
        ),
      ]);
    }

    if (contract.isActive) {
      actions.addAll([
        OutlinedButton.icon(
          onPressed: provider.isLoading || _uploadingPhoto
              ? null
              : () => _addPhoto(provider, contract.id),
          icon: _uploadingPhoto
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.add_a_photo_outlined),
          label: Text(_uploadingPhoto ? 'Subiendo foto…' : 'Agregar foto'),
        ),
        TextButton.icon(
          onPressed: provider.isLoading
              ? null
              : () => _showCancelDialog(provider, contract),
          icon: const Icon(Icons.cancel_outlined),
          label: const Text('Cancelar contrato'),
        ),
      ]);
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Acciones', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...actions.map(
              (action) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: action,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addComment(ContractsProvider provider, String id) async {
    final body = _commentController.text.trim();
    if (body.isEmpty) return;
    final success = await provider.addComment(id: id, body: body);
    if (success && mounted) _commentController.clear();
  }

  Future<void> _addPhoto(ContractsProvider provider, String id) async {
    final description = await _askForText(
      title: 'Descripción de la foto',
      label: 'Descripción',
      confirmLabel: 'Continuar',
    );
    if (description == null || !mounted) return;

    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;

    setState(() => _uploadingPhoto = true);
    try {
      final url = await uploadContractPhoto(file);
      if (url.isEmpty) {
        throw Exception('El servidor no devolvió la URL de la foto.');
      }
      await provider.addPhoto(id: id, photo: url, description: description);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _showTermsDialog(
    ContractsProvider provider,
    ContractModel contract,
  ) async {
    final value = await showDialog<_TermsFormValue>(
      context: context,
      builder: (_) => _TermsDialog(contract: contract),
    );
    if (value == null || !mounted) return;

    await provider.setTerms(
      id: contract.id,
      salary: value.salary,
      currency: value.currency,
      startDate: value.startDate,
      duration: value.duration,
    );
  }

  Future<void> _confirmDecision(
    ContractsProvider provider,
    ContractModel contract, {
    required bool accept,
  }) async {
    final confirmed = await _confirm(
      title: accept ? 'Aceptar contrato' : 'Rechazar contrato',
      message: accept
          ? '¿Confirmas que deseas aceptar este contrato?'
          : '¿Confirmas que deseas rechazar este contrato?',
      actionLabel: accept ? 'Aceptar' : 'Rechazar',
    );
    if (!confirmed || !mounted) return;
    if (accept) {
      await provider.accept(contract.id);
    } else {
      await provider.reject(contract.id);
    }
  }

  Future<void> _showCancelDialog(
    ContractsProvider provider,
    ContractModel contract,
  ) async {
    final justification = await _askForText(
      title: 'Cancelar contrato',
      label: 'Justificación',
      confirmLabel: 'Cancelar contrato',
      maxLines: 4,
    );
    if (justification == null || !mounted) return;
    await provider.cancel(id: contract.id, justification: justification);
  }

  Future<String?> _askForText({
    required String title,
    required String label,
    required String confirmLabel,
    int maxLines = 1,
  }) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: maxLines,
          decoration: InputDecoration(labelText: label),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cerrar'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) Navigator.pop(dialogContext, value);
            },
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String actionLabel,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Volver'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(actionLabel),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.contract});

  final ContractModel contract;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    contract.jobTypeName ?? 'Contrato de trabajo',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Chip(
                  label: Text(contract.statusLabel),
                  avatar: Icon(
                    contract.isActive
                        ? Icons.check_circle_outline
                        : Icons.info_outline,
                    size: 18,
                    color: scheme.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _InfoLine(
              label: 'Mi rol',
              value: contract.myRole == 'contratante'
                  ? 'Contratante'
                  : 'Contratado',
            ),
            _InfoLine(
              label: 'Otra parte',
              value: contract.otherParty?.displayName ?? 'No disponible',
            ),
            if (contract.otherParty?.email != null)
              _InfoLine(label: 'Correo', value: contract.otherParty!.email!),
          ],
        ),
      ),
    );
  }
}

class _TermsCard extends StatelessWidget {
  const _TermsCard({required this.contract});

  final ContractModel contract;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Términos', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _InfoLine(
              label: 'Salario',
              value: contract.salary == null
                  ? 'Pendiente de definir'
                  : '${contract.salary!.toStringAsFixed(2)} ${contract.currency ?? 'DOP'}',
            ),
            _InfoLine(
              label: 'Inicio',
              value: contract.startDate == null
                  ? 'Pendiente de definir'
                  : _formatDate(contract.startDate!),
            ),
            _InfoLine(
              label: 'Duración',
              value: contract.duration ?? 'Pendiente de definir',
            ),
            if (contract.cancelJustification != null)
              _InfoLine(
                label: 'Justificación de cancelación',
                value: contract.cancelJustification!,
              ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime value) {
    final date = value.toLocal();
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _CommentComposer extends StatelessWidget {
  const _CommentComposer({
    required this.controller,
    required this.enabled,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            enabled: enabled,
            minLines: 1,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Escribe un comentario',
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: enabled ? onSend : null,
          icon: const Icon(Icons.send),
          tooltip: 'Enviar',
        ),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final ContractCommentModel comment;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person_outline)),
        title: Text(comment.by.displayName),
        subtitle: Text(comment.body),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.photo});

  final ContractPhotoModel photo;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              photo.url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.broken_image_outlined, size: 48),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              photo.description.isEmpty ? 'Sin descripción' : photo.description,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(message),
    );
  }
}

class _TermsFormValue {
  const _TermsFormValue({
    required this.salary,
    required this.currency,
    required this.startDate,
    required this.duration,
  });

  final double salary;
  final String currency;
  final DateTime startDate;
  final String duration;
}

class _TermsDialog extends StatefulWidget {
  const _TermsDialog({required this.contract});

  final ContractModel contract;

  @override
  State<_TermsDialog> createState() => _TermsDialogState();
}

class _TermsDialogState extends State<_TermsDialog> {
  late final TextEditingController _salaryController;
  late final TextEditingController _currencyController;
  late final TextEditingController _durationController;
  late DateTime _startDate;

  @override
  void initState() {
    super.initState();
    _salaryController = TextEditingController(
      text: widget.contract.salary?.toString() ?? '',
    );
    _currencyController = TextEditingController(
      text: widget.contract.currency ?? 'DOP',
    );
    _durationController = TextEditingController(
      text: widget.contract.duration ?? '',
    );
    _startDate = widget.contract.startDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _salaryController.dispose();
    _currencyController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date != null) setState(() => _startDate = date);
  }

  void _submit() {
    final salary = double.tryParse(_salaryController.text.trim());
    final currency = _currencyController.text.trim();
    final duration = _durationController.text.trim();
    if (salary == null || salary <= 0 || currency.isEmpty || duration.isEmpty) {
      return;
    }
    Navigator.pop(
      context,
      _TermsFormValue(
        salary: salary,
        currency: currency,
        startDate: _startDate,
        duration: duration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Fijar términos'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _salaryController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Salario'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _currencyController,
              decoration: const InputDecoration(labelText: 'Moneda'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(labelText: 'Duración'),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Fecha de inicio'),
              subtitle: Text(_formatDate(_startDate)),
              trailing: IconButton(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_month),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Guardar')),
      ],
    );
  }

  static String _formatDate(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
  }
}
