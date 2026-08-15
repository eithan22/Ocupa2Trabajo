class NewsItemModel {
  const NewsItemModel({
    required this.title,
    required this.image,
    required this.summary,
    required this.date,
    required this.url,
    required this.source,
  });

  final String title;
  final String image;
  final String summary;
  final DateTime date;
  final String url;
  final String source;

  factory NewsItemModel.fromJson(Map<String, dynamic> json) {
    return NewsItemModel(
      title: json['title'] as String? ?? '',
      image: json['image'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      url: json['url'] as String? ?? '',
      source: json['source'] as String? ?? '',
    );
  }
}