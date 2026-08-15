import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Mensajes del carrusel de bienvenida.
  static final List<_SlideData> _slides = [
    _SlideData(
      image: 'assets/images/slide1.jpg',
      title: 'Encuentra trabajos temporales',
      subtitle: 'Cerca de ti, publicados por otros estudiantes del ITLA',
    ),
    _SlideData(
      image: 'assets/images/slide2.jpg',
      title: 'Publica tu propia oferta',
      subtitle: 'En minutos, con foto y ubicación',
    ),
    _SlideData(
      image: 'assets/images/slide3.jpg',
      title: 'Elige al mejor candidato',
      subtitle: 'Revisa, califica y selecciona un ganador',
    ),
  ];

  // Accesos a los módulos de la app.

  static const List<_ModuleTile> _modules = [
    _ModuleTile(icon: Icons.article_outlined, label: 'Noticias', route: '/news'),
    _ModuleTile(icon: Icons.ondemand_video_outlined, label: 'Videos', route: '/videos'),
    _ModuleTile(icon: Icons.info_outline, label: 'Acerca de', route: '/about'),
    _ModuleTile(icon: Icons.explore_outlined, label: 'Explorar ofertas', route: null),
    _ModuleTile(icon: Icons.map_outlined, label: 'Mapa de ofertas', route: null),
    _ModuleTile(icon: Icons.campaign_outlined, label: 'Publicar oferta', route: null),
    _ModuleTile(icon: Icons.work_outline, label: 'Mis ofertas', route: null),
    _ModuleTile(icon: Icons.assignment_outlined, label: 'Mis aplicaciones', route: null),
    _ModuleTile(icon: Icons.badge_outlined, label: 'Mis experiencias', route: null),
    _ModuleTile(icon: Icons.description_outlined, label: 'Mis contratos', route: null),
    _ModuleTile(icon: Icons.payments_outlined, label: 'Mis pagos', route: null),
  ];

  @override
  Widget build(BuildContext context) {
    // Alto del carrusel: 55% de la pantalla
    // tipo banner sin dejar el resto del contenido sin espacio.
    final carouselHeight = MediaQuery.of(context).size.height * 0.55;

    return Scaffold(
      appBar: AppBar(title: const Text('Ocupa2')),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              // --- Carrusel de bienvenida,
              FlutterCarousel(
                options: FlutterCarouselOptions(
                  height: carouselHeight,
                  viewportFraction: 1, // 1 slide llena toda la pantalla, sin ver el borde del siguiente
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 4),
                  showIndicator: true,
                  slideIndicator: CircularSlideIndicator(),
                ),
                items: _slides.map((slide) => _SlideCard(slide: slide)).toList(),
              ),

              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Bienvenido a Ocupa2',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 28),



              //  Accesos a los módulos de la app
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Explora la app', style: Theme.of(context).textTheme.titleMedium),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.3,
                  children: _modules.map((module) => _ModuleCard(module: module)).toList(),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}


// Datos y widget de cada tarjeta del carrusel


class _SlideData {
  const _SlideData({required this.image, required this.title, required this.subtitle});
  final String image;
  final String title;
  final String subtitle;
}

class _SlideCard extends StatelessWidget {
  const _SlideCard({required this.slide});
  final _SlideData slide;

  @override
  Widget build(BuildContext context) {
    // Sin margen horizontal ni bordes redondeados la foto llega de extremo a extremo de la pantalla.

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(slide.image),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        // Degradado oscuro solo abajo, para que el texto blanco se lea
        // bien encima de la foto sin oscurecer toda la imagen.
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
            stops: const [0.4, 1.0],
          ),
        ),
        padding: const EdgeInsets.all(24),
        alignment: Alignment.bottomLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              slide.title,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              slide.subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}


// Datos y widget de cada tarjeta de módulo


class _ModuleTile {
  const _ModuleTile({required this.icon, required this.label, this.route});
  final IconData icon;
  final String label;
  final String? route; // null = módulo aún no construido por el equipo
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.module});
  final _ModuleTile module;

  // true si la ruta ya existe y se puede navegar; false si el módulo
  // todavía no lo construye nadie del equipo.
  bool get _isReady => module.route != null;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _isReady ? null : Theme.of(context).colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: () {
          if (_isReady) {
            context.push(module.route!);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Próximamente')),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                module.icon,
                size: 32,
                color: _isReady ? Theme.of(context).colorScheme.primary : Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                module.label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: _isReady ? null : Colors.grey),
              ),
              if (!_isReady) ...[
                const SizedBox(height: 4),
                Text('Próximamente', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}