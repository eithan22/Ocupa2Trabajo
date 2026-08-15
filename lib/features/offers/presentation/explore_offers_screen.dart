import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/offers_provider.dart';
import '../../../models/offer_model.dart';

class ExploreOffersScreen extends StatefulWidget {
  const ExploreOffersScreen({super.key});

  @override
  State<ExploreOffersScreen> createState() => _ExploreOffersScreenState();
}

class _ExploreOffersScreenState extends State<ExploreOffersScreen> {
  String? _selectedJobTypeKey;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<OffersProvider>();
      provider.fetchJobTypes();
      provider.fetchOffers();
    });
  }

  void _onFilterChanged(String? jobTypeKey) {
    setState(() {
      _selectedJobTypeKey = _selectedJobTypeKey == jobTypeKey ? null : jobTypeKey;
    });

    context.read<OffersProvider>().fetchOffers(jobTypeKey: _selectedJobTypeKey);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OffersProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar Ofertas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            tooltip: 'Ver en Mapa',
            onPressed: () => context.push('/offers-map'), // Navegamos al mapa
          ),
        ],
      ),
      body: Column(
        children: [
          // FILTROS VISUALES
          if (provider.jobTypes.isNotEmpty)
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: provider.jobTypes.length,
                itemBuilder: (context, index) {
                  final jobType = provider.jobTypes[index];
                  final isSelected = _selectedJobTypeKey == jobType.key;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(jobType.name),
                      selected: isSelected,
                      onSelected: (_) => _onFilterChanged(jobType.key),
                    ),
                  );
                },
              ),
            ),

          // LISTADO DE OFERTAS
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.offers.isEmpty
                ? const Center(child: Text('No hay ofertas disponibles.'))
                : RefreshIndicator(
              onRefresh: () => provider.fetchOffers(jobTypeKey: _selectedJobTypeKey),
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: provider.offers.length,
                itemBuilder: (context, index) {
                  final offer = provider.offers[index];
                  return _OfferCard(offer: offer);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/publish-offer'),
        tooltip: 'Publicar Oferta',
        child: const Icon(Icons.add),
      ),
    );
  }
}


class _OfferCard extends StatelessWidget {
  final OfferModel offer;

  const _OfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(offer.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(offer.description, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(offer.contractType.toUpperCase(), style: const TextStyle(fontSize: 10)),
                  visualDensity: VisualDensity.compact,
                ),
                const Spacer(),
                const Text('Ver detalle →', style: TextStyle(color: Colors.blue)),
              ],
            ),
          ],
        ),
        onTap: () {

          context.push('/offer-detail/${offer.id}');
        },
      ),
    );
  }
}