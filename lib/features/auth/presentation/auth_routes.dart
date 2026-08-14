import 'package:go_router/go_router.dart';

import 'change_password_screen.dart';
import 'complete_profile_screen.dart';
import 'forgot_password_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';

/// Rutas del módulo de auth. `app_router.dart` las concatena con
/// `...authRoutes` junto a las de los demás módulos.
final List<RouteBase> authRoutes = [
  GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
  GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
  GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
  GoRoute(path: '/complete-profile', builder: (context, state) => const CompleteProfileScreen()),
  GoRoute(path: '/change-password', builder: (context, state) => const ChangePasswordScreen()),
];
