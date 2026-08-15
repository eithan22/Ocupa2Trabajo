class VideoModel {
  const VideoModel({
    required this.id,
    required this.youtubeId,
    required this.url,
    required this.title,
    required this.description,
    required this.thumbnail,
  });

  final String id;
  final String youtubeId;
  final String url;
  final String title;
  final String description;
  final String thumbnail;

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] as String? ?? '',
      youtubeId: json['youtubeId'] as String? ?? '',
      url: json['url'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      thumbnail: json['thumbnail'] as String? ?? '',
    );
  }
}