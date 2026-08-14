import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/inline_error_banner.dart';
import '../providers/auth_provider.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  final _cedulaController = TextEditingController();
  String? _gender;
  DateTime? _birthDate;
  bool _dateTouched = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cedulaController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Fecha de nacimiento',
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _dateTouched = true;
      });
    }
  }

  Future<void> _submit() async {
    final formValid = _formKey.currentState!.validate();
    setState(() => _dateTouched = true);
    if (!formValid || _birthDate == null) return;

    final authProvider = context.read<AuthProvider>();
    final cedulaDigits = _cedulaController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final success = await authProvider.updateProfile(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      cedula: cedulaDigits,
      gender: _gender!,
      birthDate: _birthDate!,
    );

    if (success && mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final dateLabel = _birthDate == null
        ? 'Selecciona tu fecha de nacimiento'
        : DateFormat('dd/MM/yyyy').format(_birthDate!);

    return Scaffold(
      appBar: AppBar(title: const Text('Completa tu perfil'), automaticallyImplyLeading: false),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Antes de continuar, necesitamos algunos datos para completar tu perfil.',
                ),
                const SizedBox(height: 16),
                if (authProvider.status == AuthStatus.error && authProvider.errorMessage != null)
                  InlineErrorBanner(message: authProvider.errorMessage!),
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (value) {
                    if (value == null || value.trim().length < 2) {
                      return 'El nombre debe tener al menos 2 caracteres.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'Apellido'),
                  validator: (value) {
                    if (value == null || value.trim().length < 2) {
                      return 'El apellido debe tener al menos 2 caracteres.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cedulaController,
                  decoration: const InputDecoration(
                    labelText: 'Cédula',
                    helperText: '11 dígitos, sin guiones',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final digits = (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
                    if (digits.length != 11) return 'La cédula debe tener 11 dígitos.';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _gender,
                  decoration: const InputDecoration(labelText: 'Género'),
                  items: const [
                    DropdownMenuItem(value: 'masculino', child: Text('Masculino')),
                    DropdownMenuItem(value: 'femenino', child: Text('Femenino')),
                    DropdownMenuItem(value: 'otro', child: Text('Otro')),
                  ],
                  onChanged: (value) => setState(() => _gender = value),
                  validator: (value) => value == null ? 'Selecciona un género.' : null,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _pickBirthDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Fecha de nacimiento'),
                    child: Text(dateLabel),
                  ),
                ),
                if (_dateTouched && _birthDate == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 12),
                    child: Text(
                      'La fecha de nacimiento es obligatoria.',
                      style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: authProvider.isLoading ? null : _submit,
                  child: authProvider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Guardar y continuar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
