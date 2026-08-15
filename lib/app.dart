import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/network/dio_client.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/content/providers/content_provider.dart';

class OcupaApp extends StatefulWidget {
  const OcupaApp({super.key});

  @override
  State<OcupaApp> createState() => _OcupaAppState();
}

class _OcupaAppState extends State<OcupaApp> {
  late final AuthProvider _authProvider;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider();
    DioClient.instance.setOnUnauthorized(_authProvider.handleUnauthorized);
    _router = buildAppRouter(_authProvider);
    _authProvider.bootstrap();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: _authProvider),
        ChangeNotifierProvider<ContentProvider>(create: (_) => ContentProvider()),
        // Los demás módulos (P2-P5) agregan aquí sus propios ChangeNotifierProvider.
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isBootstrapping) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              home: const _SplashScreen(),
            );
          }

          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Ocupa2',
            theme: AppTheme.light,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
