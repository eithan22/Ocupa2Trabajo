import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/liked_offer_model.dart';
import '../providers/applications_provider.dart';

/// GET /me/likes — "Me gusta": ofertas que el usuario marcó con like.
/// POST/DELETE /offers/{id}/like también viven en este módulo, pero se
/// disparan desde aquí (quitar like) y desde las tarjetas de oferta de P2
/// (dar like) usando el mismo `ApplicationsProvider.toggleLike`.
class LikedOffersScreen extends StatefulWidget {
  const LikedOffersScreen({super.key});

  @override
  State<LikedOffersScreen> createState() => _LikedOffersScreenState();
}

class _LikedOffersScreenState extends State<LikedOffersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationsProvider>().loadMyLikedOffers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Me gusta')),
      body: Consumer<ApplicationsProvider>(
        builder: (context, provider, _) {
          switch (provider.likedOffersStatus) {
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
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text(provider.likedOffersError ?? 'Error desconocido', textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: provider.loadMyLikedOffers,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );

            case LoadStatus.success:
              if (provider.likedOffers.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'No tienes ofertas con like todavía. Explora ofertas y toca el corazón '
                      'para guardarlas aquí.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: provider.loadMyLikedOffers,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.likedOffers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final offer = provider.likedOffers[index];
                    return _LikedOfferCard(offer: offer);
                  },
                ),
              );
          }
        },
      ),
    );
  }
}

class _LikedOfferCard extends StatelessWidget {
  final LikedOfferModel offer;

  const _LikedOfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: offer.photoUrl != null
              ? CachedNetworkImage(
                  imageUrl: offer.photoUrl!,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => const Icon(Icons.image_not_supported),
                )
              : Container(
                  width: 56,
                  height: 56,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.work_outline, color: Colors.grey),
                ),
        ),
        title: Text(offer.title),
        subtitle: offer.jobTypeName != null ? Text(offer.jobTypeName!) : null,
        trailing: LikeButton(offerId: offer.id),
        onTap: () {
          // Detalle de oferta es propiedad de Persona 2 (go_router):
          // context.push('/offers/${offer.id}');
        },
      ),
    );
  }
}

/// Botón de "me gusta" reutilizable, pensado para embeberse en las tarjetas
/// de oferta de Persona 2 (`explore_offers_screen.dart`,
/// `offer_detail_screen.dart`) sin que P2 tenga que reimplementar la lógica
/// de like/unlike.
class LikeButton extends StatelessWidget {
  final String offerId;

  const LikeButton({super.key, required this.offerId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ApplicationsProvider>();
    final liked = provider.isOfferLiked(offerId);
    return IconButton(
      icon: Icon(liked ? Icons.favorite : Icons.favorite_border, color: liked ? Colors.red : null),
      onPressed: () => context.read<ApplicationsProvider>().toggleLike(offerId),
    );
  }
}
