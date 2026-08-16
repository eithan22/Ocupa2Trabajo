import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_routes.dart';
import '../../features/auth/providers/auth_provider.dart';
// import '../../features/offers/presentation/offers_routes.dart';
// import '../../features/applications/presentation/applications_routes.dart';
import '../../features/contracts_payments/presentation/contracts_payments_routes.dart';
import '../../features/content/presentation/content_routes.dart';
import '../../features/applications/presentation/applications_routes.dart';
import '../../features/offers/presentation/offers_routes.dart';

const _publicRoutes = {'/login', '/register', '/forgot-password'};

/// Construye el GoRouter de la app. Solo importa y concatena listas de
/// rutas por módulo con `...`; cada módulo agrega su propia lista aquí
/// cuando esté listo (spreads comentados abajo).
///
///
final GoRouter appRouter = GoRouter(
  initialLocation: '/login',

  routes: [...authRoutes, ...offersRoutes],
);

GoRouter buildAppRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authProvider,
    redirect: (context, state) => _handleRedirect(authProvider, state),

    routes: [
      ...authRoutes,
      ...offersRoutes,
      ...applicationsRoutes,
      ...contractsPaymentsRoutes,
      ...contentRoutes,
    ],
  );
}

/// Guard único de sesión. Casos explícitos, en orden:
/// 1. Sin token y no es una ruta pública -> `/login`.
/// 2. Con token y perfil incompleto (fuera de `/complete-profile`) -> forzar `/complete-profile`.
/// 3. Con token, perfil completo, intentando entrar a `/login` o `/register` -> `/home`.
String? _handleRedirect(AuthProvider authProvider, GoRouterState state) {
  final hasToken = authProvider.isLoggedIn;
  final profileCompleted = authProvider.isProfileCompleted;
  final location = state.matchedLocation;

  if (!hasToken && !_publicRoutes.contains(location)) {
    return '/login';
  }

  if (hasToken && !profileCompleted && location != '/complete-profile') {
    return '/complete-profile';
  }

  if (hasToken &&
      profileCompleted &&
      (location == '/login' || location == '/register')) {
    return '/home';
  }

  return null;
}
