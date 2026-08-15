import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/widgets/app_drawer.dart';
import '../../../models/video_model.dart';
import '../providers/content_provider.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContentProvider>().loadVideos();
    });
  }

  // Intenta abrir directo, en vez de preguntar primero con canLaunchUrl
  // (en Android 11+ esa pregunta suele devolver "no" aunque sí se pueda
  // abrir, si el manifiesto no declara los <queries> correspondientes).
  // Si falla de verdad, muestra un aviso en vez de quedarse en silencio.
  Future<void> _openVideo(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el video.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Videos')),
      drawer: const AppDrawer(),
      body: Consumer<ContentProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingVideos) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.videosError != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(provider.videosError!, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: () => provider.loadVideos(), child: const Text('Reintentar')),
                ],
              ),
            );
          }

          if (provider.videos.isEmpty) {
            return const Center(child: Text('No hay videos por ahora.'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadVideos(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.videos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _VideoCard(video: provider.videos[index], onTap: _openVideo),
            ),
          );
        },
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.video, required this.onTap});
  final VideoModel video;
  final void Function(String url) onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onTap(video.url),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CachedNetworkImage(
                  imageUrl: video.thumbnail,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    height: 180,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.ondemand_video_outlined, size: 48),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                  padding: const EdgeInsets.all(12),
                  child: const Icon(Icons.play_arrow, color: Colors.white, size: 36),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(video.title, style: Theme.of(context).textTheme.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(video.description, style: Theme.of(context).textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}