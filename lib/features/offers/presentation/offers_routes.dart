import 'package:go_router/go_router.dart';

// Importamos las pantallas que acabamos de crear
import 'explore_offers_screen.dart';
import 'offers_map_screen.dart';
import 'publish_offer_screen.dart';
import 'offer_detail_screen.dart';
// import 'my_offers_screen.dart'; // TODO: Descomentar cuando crees la pantalla de Tus Ofertas

/// Rutas correspondientes al módulo de la Persona 2 (Catálogo y Ofertas)
final List<RouteBase> offersRoutes = [
  GoRoute(
    // Esta podría ser la ruta a la que se navega desde el menú principal
    path: '/explore-offers',
    builder: (context, state) => const ExploreOffersScreen(),
  ),
  GoRoute(
    path: '/offers-map',
    builder: (context, state) => const OffersMapScreen(),
  ),
  GoRoute(
    path: '/publish-offer',
    builder: (context, state) => const PublishOfferScreen(),
  ),
  GoRoute(
    // Recibe el ID de la oferta como parámetro dinámico
    path: '/offer-detail/:id',
    builder: (context, state) {
      final offerId = state.pathParameters['id']!;
      return OfferDetailScreen(offerId: offerId);
    },
  ),

  // Aquí agregarás tu última pantalla cuando la termines:
  // GoRoute(
  //   path: '/my-offers',
  //   builder: (context, state) => const MyOffersScreen(),
  // ),
];