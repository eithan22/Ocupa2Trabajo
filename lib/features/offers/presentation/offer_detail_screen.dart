import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_drawer.dart';
import '../providers/offers_provider.dart';
import '../../applications/presentation/apply_to_offer_widget.dart';

class OfferDetailScreen extends StatefulWidget {
  final String offerId;

  const OfferDetailScreen({super.key, required this.offerId});

  @override
  State<OfferDetailScreen> createState() => _OfferDetailScreenState();
}

class _OfferDetailScreenState extends State<OfferDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OffersProvider>().fetchOfferDetail(widget.offerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OffersProvider>();
    final offer = provider.currentOffer;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de la Oferta')),
      drawer: const AppDrawer(),
      body: provider.isLoading || offer == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (offer.imageUrl != null && offer.imageUrl!.isNotEmpty)
                    Container(
                      width: double.infinity,
                      height: 200,

                      margin: const EdgeInsets.only(bottom: 16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(offer.imageUrl!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      height: 200,

                      margin: const EdgeInsets.only(bottom: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.work,
                        size: 64,
                        color: Colors.grey,
                      ),
                    ),

                  Text(
                    offer.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Chip(
                        label: Text(offer.contractType.toUpperCase()),
                        backgroundColor: Colors.blue.shade100,
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(offer.status.toUpperCase()),
                        backgroundColor: offer.status == 'active'
                            ? Colors.green.shade100
                            : Colors.grey.shade300,
                      ),
                    ],
                  ),
                  if (offer.salary != null) ...[
                    const SizedBox(height: 8),
                    Chip(
                      avatar: const Icon(Icons.payments_outlined, size: 18),
                      label: Text(
                        'Pago: ${offer.salary!.toStringAsFixed(2)} DOP',
                      ),
                      backgroundColor: Colors.green.shade100,
                    ),
                  ],
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      border: Border.all(color: Colors.orange.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            offer.contratante != null
                                ? 'Publicado por: ${offer.contratante}'
                                : 'Identidad del publicante oculta por privacidad',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Descripción del trabajo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    offer.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const Divider(height: 48, thickness: 1),

                  const Text(
                    'Postúlate a esta oferta',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ApplyToOfferWidget(
                    offerId: offer.id,
                    questions: offer.questions,
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
