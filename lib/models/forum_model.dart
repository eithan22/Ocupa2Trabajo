class ForumAuthorModel {
  const ForumAuthorModel({
    required this.id,
    required this.name,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String? avatarUrl;

  factory ForumAuthorModel.fromJson(dynamic value) {
    if (value is String) {
      return ForumAuthorModel(id: '', name: value);
    }

    final json = value is Map
        ? Map<String, dynamic>.from(value)
        : <String, dynamic>{};
    final firstName = _asString(json['firstName'] ?? json['first_name']);
    final lastName = _asString(json['lastName'] ?? json['last_name']);
    final combinedName = [
      firstName,
      lastName,
    ].where((part) => part.isNotEmpty).join(' ');

    return ForumAuthorModel(
      id: _asString(json['id'] ?? json['userId'] ?? json['user_id']),
      name: _asString(
        json['displayName'] ??
            json['display_name'] ??
            json['fullName'] ??
            json['full_name'] ??
            json['name'] ??
            (combinedName.isEmpty ? json['email'] : combinedName),
      ),
      avatarUrl: _nullableString(
        json['avatarUrl'] ?? json['avatar_url'] ?? json['avatar'],
      ),
    );
  }
}

class ForumCommentModel {
  const ForumCommentModel({
    required this.id,
    required this.body,
    required this.author,
    required this.createdAt,
  });

  final String id;
  final String body;
  final ForumAuthorModel author;
  final DateTime createdAt;

  factory ForumCommentModel.fromJson(Map<String, dynamic> json) {
    return ForumCommentModel(
      id: _asString(json['id']),
      body: _asString(json['body'] ?? json['content'] ?? json['comment']),
      author: ForumAuthorModel.fromJson(
        json['author'] ?? json['user'] ?? json['createdBy'],
      ),
      createdAt: _dateFrom(
        json['createdAt'] ?? json['created_at'] ?? json['date'],
      ),
    );
  }
}

class ForumTopicModel {
  const ForumTopicModel({
    required this.id,
    required this.title,
    required this.body,
    required this.author,
    required this.createdAt,
    this.comments = const [],
    this.commentsCount,
  });

  final String id;
  final String title;
  final String body;
  final ForumAuthorModel author;
  final DateTime createdAt;
  final List<ForumCommentModel> comments;
  final int? commentsCount;

  factory ForumTopicModel.fromJson(Map<String, dynamic> json) {
    final rawComments = json['comments'];
    final comments = rawComments is List
        ? rawComments
              .whereType<Map>()
              .map(
                (item) =>
                    ForumCommentModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
        : const <ForumCommentModel>[];

    return ForumTopicModel(
      id: _asString(json['id'] ?? json['topicId'] ?? json['topic_id']),
      title: _asString(json['title'] ?? json['subject']),
      body: _asString(json['body'] ?? json['content'] ?? json['description']),
      author: ForumAuthorModel.fromJson(
        json['author'] ?? json['user'] ?? json['createdBy'],
      ),
      createdAt: _dateFrom(
        json['createdAt'] ?? json['created_at'] ?? json['date'],
      ),
      comments: comments,
      commentsCount: _asInt(json['commentsCount'] ?? json['comments_count']),
    );
  }
}

String _asString(dynamic value) => value?.toString() ?? '';

String? _nullableString(dynamic value) {
  final result = _asString(value);
  return result.isEmpty ? null : result;
}

DateTime _dateFrom(dynamic value) {
  final raw = _asString(value).trim();
  if (raw.isEmpty) return DateTime.now();

  // Las fechas completas del API vienen en UTC. Las fechas sin zona horaria
  // también se interpretan como UTC para evitar que el navegador muestre el
  // día siguiente al convertirlas a la hora local de Santo Domingo.
  final isDateOnly = RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(raw);
  if (isDateOnly) return DateTime.tryParse(raw) ?? DateTime.now();

  final hasTimezone =
      raw.endsWith('Z') || RegExp(r'[+-]\d{2}:?\d{2}$').hasMatch(raw);
  final parsed = DateTime.tryParse(hasTimezone ? raw : '${raw}Z');
  return parsed?.toLocal() ?? DateTime.now();
}

int? _asInt(dynamic value) =>
    value is num ? value.toInt() : int.tryParse(_asString(value));
