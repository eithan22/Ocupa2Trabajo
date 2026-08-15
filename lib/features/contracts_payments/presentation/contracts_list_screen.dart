import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../models/contract_model.dart';
import '../providers/contracts_provider.dart';

class ContractsListScreen extends StatefulWidget {
  const ContractsListScreen({super.key});

  @override
  State<ContractsListScreen> createState() => _ContractsListScreenState();
}

class _ContractsListScreenState extends State<ContractsListScreen> {
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContractsProvider>().loadContracts();
    });
  }

  void _changeFilter(String value) {
    setState(() => _filter = value);
    context.read<ContractsProvider>().loadContracts(
      status: value == 'all' ? null : value,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ContractsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis contratos'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _filter,
            onSelected: _changeFilter,
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'all', child: Text('Todos')),
              PopupMenuItem(value: 'active', child: Text('Activos')),
              PopupMenuItem(value: 'inactive', child: Text('Inactivos')),
            ],
          ),
        ],
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(ContractsProvider provider) {
    if (provider.isLoading && provider.contracts.isEmpty) {
      return const LoadingView(message: 'Cargando contratos…');
    }
    if (provider.errorMessage != null && provider.contracts.isEmpty) {
      return ErrorView(
        message: provider.errorMessage!,
        onRetry: () =>
            provider.loadContracts(status: _filter == 'all' ? null : _filter),
      );
    }
    if (provider.contracts.isEmpty) {
      return RefreshIndicator(
        onRefresh: () =>
            provider.loadContracts(status: _filter == 'all' ? null : _filter),
        child: ListView(
          children: const [
            SizedBox(height: 180),
            Center(child: Text('No tienes contratos en este filtro.')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          provider.loadContracts(status: _filter == 'all' ? null : _filter),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: provider.contracts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) =>
            _ContractTile(contract: provider.contracts[index]),
      ),
    );
  }
}

class _ContractTile extends StatelessWidget {
  const _ContractTile({required this.contract});

  final ContractModel contract;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final statusColor = contract.isActive ? scheme.primary : scheme.secondary;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.14),
          child: Icon(Icons.description_outlined, color: statusColor),
        ),
        title: Text(contract.jobTypeName ?? 'Contrato de trabajo'),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            '${contract.myRole == 'contratante' ? 'Contratante' : 'Contratado'} · ${contract.otherParty?.displayName ?? 'Parte del contrato'}\n${contract.statusLabel}',
          ),
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/contracts/${contract.id}'),
      ),
    );
  }
}
