import 'package:go_router/go_router.dart';
import 'package:ocupa2/features/content/presentation/videos_screen.dart';

import '../../../models/news_item_model.dart';
import 'about_screen.dart';
import 'home_screen.dart';
import 'news_detail_screen.dart';
import 'news_screen.dart';

final List<RouteBase> contentRoutes = [
  GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
  GoRoute(path: '/news', builder: (context, state) => const NewsScreen()),
  GoRoute(
    path: '/news-detail',
    builder: (context, state) => NewsDetailScreen(item: state.extra as NewsItemModel),
  ),
  GoRoute(path: '/videos', builder: (context, state) => const VideosScreen()),
  GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
];