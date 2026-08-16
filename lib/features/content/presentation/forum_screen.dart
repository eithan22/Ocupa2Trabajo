import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_drawer.dart';
import '../../../models/forum_model.dart';
import '../providers/forum_provider.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ForumProvider>().loadTopics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Foro')),
      drawer: const AppDrawer(),
      body: Consumer<ForumProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingTopics) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.topicsError != null) {
            return _ErrorView(
              message: provider.topicsError!,
              onRetry: provider.loadTopics,
            );
          }
          if (provider.topics.isEmpty) {
            return RefreshIndicator(
              onRefresh: provider.loadTopics,
              child: ListView(
                children: const [
                  SizedBox(height: 220),
                  Center(child: Text('No hay temas todavía.')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadTopics,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.topics.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _TopicCard(topic: provider.topics[index]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTopic(context),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo tema'),
      ),
    );
  }

  Future<void> _showCreateTopic(BuildContext context) async {
    final created = await showDialog<bool>(
      context: context,
      builder: (_) => const _CreateTopicDialog(),
    );
    if (created == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tema creado correctamente.')),
      );
    }
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.topic});
  final ForumTopicModel topic;

  @override
  Widget build(BuildContext context) {
    final commentCount = topic.commentsCount ?? topic.comments.length;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/forum/topics/${topic.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(topic.title, style: Theme.of(context).textTheme.titleMedium),
              if (topic.body.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(topic.body, maxLines: 3, overflow: TextOverflow.ellipsis),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      topic.author.name.isEmpty
                          ? 'Estudiante'
                          : topic.author.name,
                    ),
                  ),
                  const Icon(Icons.forum_outlined, size: 16),
                  const SizedBox(width: 4),
                  Text('$commentCount'),
                  const SizedBox(width: 12),
                  Text(DateFormat('d MMM y', 'es').format(topic.createdAt)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateTopicDialog extends StatefulWidget {
  const _CreateTopicDialog();

  @override
  State<_CreateTopicDialog> createState() => _CreateTopicDialogState();
}

class _CreateTopicDialogState extends State<_CreateTopicDialog> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ForumProvider>();
    return AlertDialog(
      title: const Text('Crear tema'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
                textInputAction: TextInputAction.next,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Escribe un título.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bodyController,
                decoration: const InputDecoration(labelText: 'Contenido'),
                minLines: 3,
                maxLines: 6,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Escribe el contenido.'
                    : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: provider.isSubmitting
              ? null
              : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: provider.isSubmitting ? null : _submit,
          child: provider.isSubmitting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Publicar'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await context.read<ForumProvider>().createTopic(
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
    );
    if (!mounted) return;
    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo crear el tema.')),
      );
    }
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
