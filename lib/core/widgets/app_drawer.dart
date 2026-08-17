import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/providers/auth_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              child: Text(
                'Ocupa2',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Inicio'),
              onTap: () => _goTo(context, '/home'),
            ),
            ListTile(
              leading: const Icon(Icons.article_outlined),
              title: const Text('Noticias'),
              onTap: () => _goTo(context, '/news'),
            ),

            ListTile(
              leading: const Icon(Icons.ondemand_video_outlined),
              title: const Text('Videos'),
              onTap: () => _goTo(context, '/videos'),
            ),
            ListTile(
              leading: const Icon(Icons.forum_outlined),
              title: const Text('Foro'),
              onTap: () => _goTo(context, '/forum'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.explore_outlined),
              title: const Text('Explorar ofertas'),
              onTap: () => _goTo(context, '/explore-offers'),
            ),
            ListTile(
              leading: const Icon(Icons.map_outlined),
              title: const Text('Mapa de ofertas'),
              onTap: () => _goTo(context, '/offers-map'),
            ),
            ListTile(
              leading: const Icon(Icons.campaign_outlined),
              title: const Text('Publicar oferta'),
              onTap: () => _goTo(context, '/publish-offer'),
            ),
            ListTile(
              leading: const Icon(Icons.work_outline),
              title: const Text('Mis ofertas'),
              onTap: () => _goTo(context, '/my-offers'),
            ),
            ListTile(
              leading: const Icon(Icons.assignment_outlined),
              title: const Text('Mis aplicaciones'),
              onTap: () => _goTo(context, '/my-applications'),
            ),
            ListTile(
              leading: const Icon(Icons.work_history_outlined),
              title: const Text('Mis experiencias'),
              onTap: () => _goTo(context, '/my-experiences'),
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Mis contratos'),
              onTap: () => _goTo(context, '/contracts'),
            ),
            ListTile(
              leading: const Icon(Icons.payments_outlined),
              title: const Text('Mis pagos'),
              onTap: () => _goTo(context, '/payments'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Acerca de'),
              onTap: () => _goTo(context, '/about'),
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Cambiar contraseña'),
              onTap: () => _goTo(context, '/change-password'),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () {
                Navigator.of(context).pop();
                context.read<AuthProvider>().logout();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _goTo(BuildContext context, String path) {
    Navigator.of(context).pop();
    context.go(path);
  }
}
