import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_drawer.dart';
import '../../../models/application_model.dart';
import '../providers/applications_provider.dart';

/// GET /offers/{id}/applications — solo visible para el dueño de la oferta.
///
/// Este es el módulo "Mis ofertas publicadas → ver aplicantes, calificar,
/// descartar y elegir ganador" de la consigna. Se llega aquí desde
/// `my_offers_screen.dart` de Persona 2 navegando por `offerId`
/// (ruta independiente en go_router, sin dependencia de compilación con P2 —
/// ver Punto de integración #5 del README).
///
/// Ejemplo de navegación desde el módulo de P2:
/// ```dart
/// context.push('/my-offers/${offer.id}/applicants');
/// ```
class ApplicantsListScreen extends StatefulWidget {
  final String offerId;
  final String? offerTitle;

  const ApplicantsListScreen({
    super.key,
    required this.offerId,
    this.offerTitle,
  });

  @override
  State<ApplicantsListScreen> createState() => _ApplicantsListScreenState();
}

class _ApplicantsListScreenState extends State<ApplicantsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationsProvider>().loadApplicantsForOffer(
        widget.offerId,
      );
    });
  }

  Future<void> _confirmAndChooseWinner(ApplicationModel application) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elegir ganador'),
        content: Text(
          '¿Seguro que quieres elegir a "${application.applicantName ?? 'este aplicante'}" '
          'como ganador? Esto crea el contrato automáticamente y no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final provider = context.read<ApplicationsProvider>();
    final success = await provider.chooseWinner(application.id);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Ganador elegido! Se creó el contrato.')),
      );
      final updatedApplication = provider.applicants.firstWhere(
        (item) => item.id == application.id,
        orElse: () => application,
      );
      final contractId = updatedApplication.contractId;
      if (contractId != null && contractId.isNotEmpty && mounted) {
        context.push('/contracts/$contractId');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.applicantsError ?? 'No se pudo elegir al ganador.',
          ),
        ),
      );
    }
  }

  Future<void> _rate(ApplicationModel application) async {
    final rating = await showDialog<int>(
      context: context,
      builder: (context) =>
          _RatingDialog(initialRating: application.rating ?? 0),
    );
    if (rating == null || !mounted) return;
    await context.read<ApplicationsProvider>().rateApplicant(
      application.id,
      rating,
    );
  }

  Future<void> _discard(ApplicationModel application) async {
    await context.read<ApplicationsProvider>().discardApplicant(application.id);
  }

  Future<void> _markFinalist(ApplicationModel application) async {
    await context.read<ApplicationsProvider>().markApplicantAsFinalist(
      application.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.offerTitle ?? 'Aplicantes')),
      drawer: const AppDrawer(),
      body: Consumer<ApplicationsProvider>(
        builder: (context, provider, _) {
          switch (provider.applicantsStatus) {
            case LoadStatus.idle:
            case LoadStatus.loading:
              return const Center(child: CircularProgressIndicator());

            case LoadStatus.error:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        provider.applicantsError ?? 'Error desconocido',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () =>
                            provider.loadApplicantsForOffer(widget.offerId),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );

            case LoadStatus.success:
              if (provider.applicants.isEmpty) {
                return const Center(
                  child: Text('Todavía no hay aplicantes para esta oferta.'),
                );
              }
              final hasWinner = provider.applicants.any(
                (a) => a.status == ApplicationStatus.winner,
              );
              return RefreshIndicator(
                onRefresh: () =>
                    provider.loadApplicantsForOffer(widget.offerId),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.applicants.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final application = provider.applicants[index];
                    return _ApplicantCard(
                      application: application,
                      disableActions: hasWinner,
                      onRate: () => _rate(application),
                      onDiscard: () => _discard(application),
                      onFinalist: () => _markFinalist(application),
                      onChooseWinner: () =>
                          _confirmAndChooseWinner(application),
                    );
                  },
                ),
              );
          }
        },
      ),
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  final ApplicationModel application;
  final bool disableActions;
  final VoidCallback onRate;
  final VoidCallback onDiscard;
  final VoidCallback onFinalist;
  final VoidCallback onChooseWinner;

  const _ApplicantCard({
    required this.application,
    required this.disableActions,
    required this.onRate,
    required this.onDiscard,
    required this.onFinalist,
    required this.onChooseWinner,
  });

  static String _initial(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    return name.trim()[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDiscarded = application.status == ApplicationStatus.discarded;
    final isWinner = application.status == ApplicationStatus.winner;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Text(_initial(application.applicantName))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.applicantName ?? 'Aplicante',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        application.status.label,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                if (application.rating != null)
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      Text('${application.rating}'),
                    ],
                  ),
              ],
            ),
            if (application.comment.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(application.comment),
            ],
            if (application.answers.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...application.answers.map(
                (a) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '${a.questionLabel ?? a.questionId}: ${a.value}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ],
            if (!isWinner) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  OutlinedButton.icon(
                    onPressed: disableActions ? null : onRate,
                    icon: const Icon(Icons.star_outline, size: 18),
                    label: const Text('Calificar'),
                  ),
                  OutlinedButton.icon(
                    onPressed: (disableActions || isDiscarded)
                        ? null
                        : onDiscard,
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Descartar'),
                  ),
                  OutlinedButton.icon(
                    onPressed: (disableActions || isDiscarded)
                        ? null
                        : onFinalist,
                    icon: const Icon(Icons.flag_outlined, size: 18),
                    label: const Text('Finalista'),
                  ),
                  FilledButton.icon(
                    onPressed: (disableActions || isDiscarded)
                        ? null
                        : onChooseWinner,
                    icon: const Icon(Icons.emoji_events_outlined, size: 18),
                    label: const Text('Elegir ganador'),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 8),
              const Row(
                children: [
                  Icon(Icons.emoji_events, color: Colors.green),
                  SizedBox(width: 6),
                  Text(
                    'Ganador — contrato creado',
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RatingDialog extends StatefulWidget {
  final int initialRating;
  const _RatingDialog({required this.initialRating});

  @override
  State<_RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<_RatingDialog> {
  late int _rating = widget.initialRating;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Calificar aplicante'),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          final starIndex = index + 1;
          return IconButton(
            onPressed: () => setState(() => _rating = starIndex),
            icon: Icon(
              starIndex <= _rating ? Icons.star : Icons.star_border,
              color: Colors.amber,
            ),
          );
        }),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _rating),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
