import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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

/// Pantalla temporal de bienvenida tras iniciar sesión. Cada módulo (P2-P5)
/// reemplazará su propia sección aquí; no es parte del alcance de auth.
class _HomePlaceholderScreen extends StatelessWidget {
  const _HomePlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final displayName = user?.firstName ?? user?.nombre ?? user?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ocupa2'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => authProvider.logout(),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 64,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              Text(
                '¡Bienvenido, $displayName!',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Esta pantalla es un marcador temporal. Cada módulo (ofertas, '
                'aplicaciones, contratos, contenido) reemplazará su sección aquí.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => context.push('/change-password'),
                child: const Text('Cambiar contraseña'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
