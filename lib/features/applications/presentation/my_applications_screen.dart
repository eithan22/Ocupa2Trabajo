import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/application_model.dart';
import '../providers/applications_provider.dart';

/// GET /me/applications — "Mis aplicaciones": ofertas a las que apliqué y
/// su estado (en revisión, descartado, finalista, ganador).
class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationsProvider>().loadMyApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis aplicaciones')),
      body: Consumer<ApplicationsProvider>(
        builder: (context, provider, _) {
          switch (provider.myApplicationsStatus) {
            case LoadStatus.idle:
            case LoadStatus.loading:
              return const Center(child: CircularProgressIndicator());

            case LoadStatus.error:
              return _ErrorState(
                message: provider.myApplicationsError ?? 'Error desconocido',
                onRetry: provider.loadMyApplications,
              );

            case LoadStatus.success:
              if (provider.myApplications.isEmpty) {
                return const _EmptyState(
                  icon: Icons.assignment_outlined,
                  message: 'Todavía no has aplicado a ninguna oferta.',
                );
              }
              return RefreshIndicator(
                onRefresh: provider.loadMyApplications,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.myApplications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final application = provider.myApplications[index];
                    return _ApplicationCard(application: application);
                  },
                ),
              );
          }
        },
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final ApplicationModel application;

  const _ApplicationCard({required this.application});

  Color _statusColor(BuildContext context) {
    switch (application.status) {
      case ApplicationStatus.winner:
        return Colors.green;
      case ApplicationStatus.finalist:
        return Colors.blue;
      case ApplicationStatus.discarded:
        return Colors.red;
      case ApplicationStatus.pending:
      case ApplicationStatus.unknown:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Detalle de oferta es propiedad de Persona 2 (go_router):
          // context.push('/offers/${application.offerId}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      application.offerTitle ?? 'Oferta #${application.offerId}',
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      application.status.label,
                      style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ),
                ],
              ),
              if (application.comment.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  application.comment,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              if (application.rating != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text('${application.rating}/5'),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
