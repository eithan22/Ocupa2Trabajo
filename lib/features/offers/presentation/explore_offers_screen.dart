import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/offers_provider.dart';
import '../../../models/offer_model.dart';
import '../../../core/widgets/app_drawer.dart';

class ExploreOffersScreen extends StatefulWidget {
  const ExploreOffersScreen({super.key});

  @override
  State<ExploreOffersScreen> createState() => _ExploreOffersScreenState();
}

class _ExploreOffersScreenState extends State<ExploreOffersScreen> {
  String? _selectedJobTypeKey;
  String? _selectedContractType;

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
      _selectedJobTypeKey = _selectedJobTypeKey == jobTypeKey
          ? null
          : jobTypeKey;
    });

    _reloadOffers();
  }

  void _onContractTypeChanged(String? contractType) {
    setState(() {
      _selectedContractType = _selectedContractType == contractType
          ? null
          : contractType;
    });

    _reloadOffers();
  }

  void _reloadOffers() {
    context.read<OffersProvider>().fetchOffers(
      jobTypeKey: _selectedJobTypeKey,
      contractType: _selectedContractType,
    );
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
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // FILTROS VISUALES
          if (provider.jobTypes.isNotEmpty)
            Container(
              height: 116,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
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
                  SizedBox(
                    height: 48,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 8, top: 8),
                          child: Text('Contrato:'),
                        ),
                        _contractTypeChip('Todos', null),
                        _contractTypeChip('Temporal', 'temporal'),
                        _contractTypeChip('Fijo', 'fijo'),
                        _contractTypeChip('Por horas', 'horas'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // LISTADO DE OFERTAS
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.offers.isEmpty
                ? const Center(child: Text('No hay ofertas disponibles.'))
                : RefreshIndicator(
                    onRefresh: () => provider.fetchOffers(
                      jobTypeKey: _selectedJobTypeKey,
                      contractType: _selectedContractType,
                    ),
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

  Widget _contractTypeChip(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: _selectedContractType == value,
        onSelected: (_) => _onContractTypeChanged(value),
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
        title: Text(
          offer.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              offer.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            if (offer.salary != null)
              Text(
                'Pago: ${offer.salary!.toStringAsFixed(2)} DOP',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            if (offer.salary != null) const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(
                    offer.contractType.toUpperCase(),
                    style: const TextStyle(fontSize: 10),
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                const Spacer(),
                const Text(
                  'Ver detalle →',
                  style: TextStyle(color: Colors.blue),
                ),
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
