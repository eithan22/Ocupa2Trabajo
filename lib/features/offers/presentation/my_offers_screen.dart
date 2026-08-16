import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../models/offer_model.dart';
import '../providers/offers_provider.dart';

class MyOffersScreen extends StatefulWidget {
  const MyOffersScreen({super.key});

  @override
  State<MyOffersScreen> createState() => _MyOffersScreenState();
}

class _MyOffersScreenState extends State<MyOffersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OffersProvider>().fetchMyOffers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis ofertas')),
      body: Consumer<OffersProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.myOffers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null && provider.myOffers.isEmpty) {
            return _ErrorState(
              message: provider.errorMessage!,
              onRetry: provider.fetchMyOffers,
            );
          }
          if (provider.myOffers.isEmpty) {
            return const Center(
              child: Text('Todavía no tienes ofertas publicadas.'),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.fetchMyOffers,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.myOffers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final offer = provider.myOffers[index];
                return _OfferCard(
                  offer: offer,
                  onApplicants: () => context.push(
                    '/my-offers/${offer.id}/applicants',
                    extra: offer.title,
                  ),
                  onDeactivate: offer.status == 'active'
                      ? () => _deactivate(provider, offer)
                      : null,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _deactivate(OffersProvider provider, OfferModel offer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desactivar oferta'),
        content: Text('¿Desactivar "${offer.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await provider.deactivateOffer(offer.id);
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({
    required this.offer,
    required this.onApplicants,
    this.onDeactivate,
  });

  final OfferModel offer;
  final VoidCallback onApplicants;
  final VoidCallback? onDeactivate;

  @override
  Widget build(BuildContext context) {
    final active = offer.status == 'active';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(offer.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              offer.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Chip(label: Text(active ? 'Activa' : offer.status)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: onApplicants,
                  icon: const Icon(Icons.people_outline),
                  label: const Text('Ver aplicantes'),
                ),
                if (onDeactivate != null)
                  OutlinedButton.icon(
                    onPressed: onDeactivate,
                    icon: const Icon(Icons.pause_circle_outline),
                    label: const Text('Desactivar'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

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
