import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_drawer.dart';
import '../providers/offers_provider.dart';

class OffersMapScreen extends StatefulWidget {
  const OffersMapScreen({super.key});

  @override
  State<OffersMapScreen> createState() => _OffersMapScreenState();
}

class _OffersMapScreenState extends State<OffersMapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OffersProvider>().fetchOffers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OffersProvider>();

    final mapOffers = provider.offers
        .where((o) => o.latitude != null && o.longitude != null)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de Ofertas')),
      drawer: const AppDrawer(),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: const LatLng(18.4861, -69.9312),
          initialZoom: 12.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.itla.ocupa2',
          ),
          MarkerLayer(
            markers: mapOffers.map((offer) {
              return Marker(
                point: LatLng(offer.latitude!, offer.longitude!),
                width: 40,
                height: 40,
                child: GestureDetector(
                  onTap: () {
                    _showOfferBottomSheet(context, offer);
                  },
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showOfferBottomSheet(BuildContext context, offer) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              offer.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              offer.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.pop();
                  context.push('/offer-detail/${offer.id}');
                },
                child: const Text('Ver Oferta Completa'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
