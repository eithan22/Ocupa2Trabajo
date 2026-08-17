import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/widgets/app_drawer.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // Equipo Ocupa2

  static const List<_TeamMember> _team = [
    _TeamMember(
      name: 'Eithan Leonardo Read',
      matricula: '2024-1869',
      role: 'Contenido & Compartido',
      phone: '8298534076',
      telegram: 'Leo1025e',
      photo: 'assets/images/Eithan.jpg',
    ),
    _TeamMember(
      name: 'Elliam Perez Terrero',
      matricula: '2024-1867',
      role: 'Integrante del equipo',
      phone: '8492076425',
      telegram: 'Elli4m',
      photo: 'assets/images/Ellian.jpg',
    ),
    _TeamMember(
      name: 'Helbert García Espinal',
      matricula: '2024-1424',
      role: 'Integrante del equipo',
      phone: '8292084364',
      telegram: 'helb01',
      photo: 'assets/images/Helbert.jpg',
    ),
    _TeamMember(
      name: 'Ismael Tejeda García',
      matricula: '2024-1466',
      role: 'Integrante del equipo',
      phone: '8094136615',
      telegram: 'Ismaelteje',
      photo: 'assets/images/Ismael.jpg',
    ),
    _TeamMember(
      name: 'Luis A. Montero Alcántara',
      matricula: '2022-0782',
      role: 'Integrante del equipo',
      phone: '8094636109',
      telegram: 'Craquen52',
      photo: 'assets/images/Luis.jpg',
    ),
  ];

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    try {
      await launchUrl(uri);
    } catch (_) {
      // Silencioso: si el dispositivo no puede marcar, no rompemos la pantalla.
    }
  }

  Future<void> _openTelegram(String username) async {
    final uri = Uri.parse('https://t.me/$username');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Silencioso: si no hay Telegram/navegador disponible, no rompemos la pantalla.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de')),
      drawer: const AppDrawer(),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _team.length,

        separatorBuilder: (_, __) => const SizedBox(height: 20),
        itemBuilder: (context, index) {
          final member = _team[index];
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                radius: 28,
                backgroundImage: AssetImage(member.photo),
              ),
              title: Text(
                member.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(member.role),
                  Text('Matrícula: ${member.matricula}'),
                  Text('Teléfono: ${member.phone}'),
                  Text('Telegram: @${member.telegram}'),
                ],
              ),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (member.phone.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.phone_outlined),
                      tooltip: 'Llamar',
                      onPressed: () => _call(member.phone),
                    ),
                  IconButton(
                    icon: const Icon(Icons.send_outlined),
                    tooltip: 'Telegram',
                    onPressed: () => _openTelegram(member.telegram),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TeamMember {
  const _TeamMember({
    required this.name,
    required this.matricula,
    required this.role,
    required this.phone,
    required this.telegram,
    required this.photo,
  });

  final String name;
  final String matricula;
  final String role;
  final String phone;
  final String telegram;
  final String photo;
}
