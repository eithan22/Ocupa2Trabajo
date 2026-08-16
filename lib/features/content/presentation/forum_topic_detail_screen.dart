import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_drawer.dart';
import '../../../models/forum_model.dart';
import '../providers/forum_provider.dart';

class ForumTopicDetailScreen extends StatefulWidget {
  const ForumTopicDetailScreen({super.key, required this.topicId});
  final String topicId;

  @override
  State<ForumTopicDetailScreen> createState() => _ForumTopicDetailScreenState();
}

class _ForumTopicDetailScreenState extends State<ForumTopicDetailScreen> {
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ForumProvider>().loadTopic(widget.topicId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tema')),
      drawer: const AppDrawer(),
      body: Consumer<ForumProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingTopic) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.topicError != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(provider.topicError!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => provider.loadTopic(widget.topicId),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final topic = provider.selectedTopic;
          if (topic == null) {
            return const Center(child: Text('No se encontró el tema.'));
          }

          return Column(
            children: [
              Expanded(child: _TopicContent(topic: topic)),
              _CommentComposer(
                controller: _commentController,
                isSubmitting: provider.isSubmitting,
                onSend: () => _sendComment(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _sendComment(ForumProvider provider) async {
    final body = _commentController.text.trim();
    if (body.isEmpty) return;
    final success = await provider.addComment(
      topicId: widget.topicId,
      body: body,
    );
    if (!mounted) return;
    if (success) {
      _commentController.clear();
    } else if (provider.topicError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.topicError!)));
    }
  }
}

class _TopicContent extends StatelessWidget {
  const _TopicContent({required this.topic});
  final ForumTopicModel topic;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(topic.body),
                const SizedBox(height: 16),
                Text(
                  '${topic.author.name.isEmpty ? 'Estudiante' : topic.author.name} · ${DateFormat('d MMM y, HH:mm', 'es').format(topic.createdAt)}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Comentarios (${topic.comments.length})',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (topic.comments.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text('Sé el primero en comentar.'),
          )
        else
          ...topic.comments.map((comment) => _CommentCard(comment: comment)),
      ],
    );
  }
}

class _CommentCard extends StatelessWidget {
  const _CommentCard({required this.comment});
  final ForumCommentModel comment;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(
          comment.author.name.isEmpty ? 'Estudiante' : comment.author.name,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(comment.body),
        ),
        trailing: Text(
          DateFormat('d MMM', 'es').format(comment.createdAt),
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ),
    );
  }
}

class _CommentComposer extends StatelessWidget {
  const _CommentComposer({
    required this.controller,
    required this.isSubmitting,
    required this.onSend,
  });
  final TextEditingController controller;
  final bool isSubmitting;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Escribe un comentario…',
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: isSubmitting ? null : onSend,
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
