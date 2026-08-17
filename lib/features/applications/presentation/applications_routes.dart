import 'package:go_router/go_router.dart';

import 'applicants_list_screen.dart';
import 'experiences_screen.dart';
import 'my_applications_screen.dart';

/// Rutas del módulo "Aplicaciones y Experiencias" — solo Persona 3 edita
/// este archivo (patrón anti-conflicto descrito en el README).
///
/// En `lib/core/router/app_router.dart` (compartido, Persona 1), agregar:
/// ```dart
/// routes: [
///   ...authRoutes,
///   ...offersRoutes,
///   ...applicationsRoutes, // 👈 esta línea
///   ...contractsPaymentsRoutes,
///   ...contentRoutes,
/// ],
/// ```
final List<RouteBase> applicationsRoutes = [
  GoRoute(
    path: '/my-applications',
    builder: (context, state) => const MyApplicationsScreen(),
  ),
  GoRoute(
    path: '/my-offers/:offerId/applicants',
    builder: (context, state) {
      final offerId = state.pathParameters['offerId']!;
      final offerTitle = state.extra is String ? state.extra as String : null;
      return ApplicantsListScreen(offerId: offerId, offerTitle: offerTitle);
    },
  ),
  GoRoute(
    path: '/my-experiences',
    builder: (context, state) => const ExperiencesScreen(),
  ),
];
