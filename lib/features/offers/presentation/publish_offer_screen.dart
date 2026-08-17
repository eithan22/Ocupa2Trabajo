import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/upload_service.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/dynamic_form_field.dart';
import '../../../models/job_type_model.dart';
import '../providers/offers_provider.dart';
import '../../contracts_payments/presentation/payment_form_widget.dart';

class PublishOfferScreen extends StatefulWidget {
  const PublishOfferScreen({super.key});

  @override
  State<PublishOfferScreen> createState() => _PublishOfferScreenState();
}

class _PublishOfferScreenState extends State<PublishOfferScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _addressController = TextEditingController();
  final _salaryController = TextEditingController();

  String? _selectedJobTypeKey;
  String _selectedContractType = 'temporal';
  final Map<String, dynamic> _dynamicAnswers = {};

  String? _uploadedImageUrl;
  Uint8List? _imagePreviewBytes;
  String? _paymentId;
  bool _uploadingImage = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OffersProvider>().fetchJobTypes();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _addressController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    final bytes = await picked.readAsBytes();
    setState(() {
      _uploadingImage = true;
      _imagePreviewBytes = bytes;
      _uploadedImageUrl = null;
    });
    try {
      final url = await UploadService().uploadImageBytes(
        bytes: bytes,
        filename: picked.name,
      );
      if (mounted) setState(() => _uploadedImageUrl = url);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
    }
  }

  void _submitOffer() async {
    if (!_formKey.currentState!.validate()) return;

    if (_uploadedImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes subir una foto obligatoria.')),
      );
      return;
    }

    if (_paymentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes completar el pago de 1 USD.')),
      );
      return;
    }

    final salary = double.tryParse(
      _salaryController.text.trim().replaceAll(',', '.'),
    );
    if (salary == null || salary <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Indica un monto de pago válido para la oferta.'),
        ),
      );
      return;
    }

    final provider = context.read<OffersProvider>();

    final offerData = {
      'title': _titleController.text.trim(),
      'description': _descController.text.trim(),
      'address': _addressController.text.trim(),
      'jobTypeKey': _selectedJobTypeKey,
      'contractType': _selectedContractType,
      'photo': _uploadedImageUrl,
      'paymentId': _paymentId,
      'payment': {'amount': salary, 'currency': 'DOP'},
      'customAnswers': _dynamicAnswers,
    };

    final success = await provider.publishOffer(offerData);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Oferta publicada con éxito!')),
      );
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Error desconocido')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OffersProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Publicar Oferta')),
      drawer: const AppDrawer(),
      body: provider.isLoading && provider.jobTypes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : provider.jobTypes.isEmpty && provider.errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(provider.errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: provider.fetchJobTypes,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título de la Oferta *',
                      ),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción *',
                      ),
                      maxLines: 3,
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Dirección / ubicación *',
                        hintText: 'Ej. Santo Domingo, Distrito Nacional',
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'La dirección es obligatoria'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _salaryController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Monto de pago de la oferta *',
                        hintText: 'Ej. 25000',
                        prefixText: 'DOP ',
                      ),
                      validator: (value) {
                        final amount = double.tryParse(
                          (value ?? '').trim().replaceAll(',', '.'),
                        );
                        if (amount == null || amount <= 0) {
                          return 'Indica un monto mayor que 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 3. Tipo de Contrato
                    DropdownButtonFormField<String>(
                      initialValue: _selectedContractType,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Contrato *',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'temporal',
                          child: Text('Temporal'),
                        ),
                        DropdownMenuItem(value: 'fijo', child: Text('Fijo')),
                        DropdownMenuItem(
                          value: 'horas',
                          child: Text('Por Horas'),
                        ),
                      ],
                      onChanged: (val) =>
                          setState(() => _selectedContractType = val!),
                    ),
                    const SizedBox(height: 16),

                    // 4. Tipo de Empleo
                    DropdownButtonFormField<String>(
                      initialValue: _selectedJobTypeKey,
                      decoration: const InputDecoration(
                        labelText: 'Categoría de Empleo *',
                      ),
                      items: provider.jobTypes.map((JobTypeModel jobType) {
                        return DropdownMenuItem<String>(
                          value: jobType.key,
                          child: Text(jobType.name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedJobTypeKey = val;
                          _dynamicAnswers.clear();
                        });
                      },
                      validator: (v) =>
                          v == null ? 'Selecciona una categoría' : null,
                    ),
                    const SizedBox(height: 16),

                    // 5. CAMPOS DINÁMICOS
                    if (_selectedJobTypeKey != null) ...[
                      const Divider(),
                      const Text(
                        'Información Específica',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ..._buildDynamicFields(provider.jobTypes),
                      const Divider(),
                    ],

                    // 6. FOTO OBLIGATORIA (Integración Persona 5)
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.grey.shade200,
                      child: Column(
                        children: [
                          const Text('Foto de la oferta'),
                          if (_imagePreviewBytes != null) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                _imagePreviewBytes!,
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          ElevatedButton.icon(
                            icon: const Icon(Icons.upload),
                            label: Text(
                              _uploadingImage
                                  ? 'Subiendo foto…'
                                  : 'Seleccionar foto',
                            ),
                            onPressed: _uploadingImage
                                ? null
                                : _pickAndUploadImage,
                          ),
                          if (_uploadedImageUrl != null)
                            const Text(
                              '✅ Foto adjuntada',
                              style: TextStyle(color: Colors.green),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 7. PAGO DE 1 USD (Integración Persona 4)
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.blue.shade50,
                      child: Column(
                        children: [
                          const Text('Pago de publicación'),
                          const SizedBox(height: 12),
                          PaymentFormWidget(
                            onPaymentApproved: (paymentId) {
                              setState(() {
                                _paymentId = paymentId;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // BOTÓN SUBMIT
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: provider.isLoading ? null : _submitOffer,
                        child: provider.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('Publicar Oferta'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  List<Widget> _buildDynamicFields(List<JobTypeModel> allJobTypes) {
    final selectedJobType = allJobTypes.firstWhere(
      (jt) => jt.key == _selectedJobTypeKey,
    );

    return selectedJobType.customFields.map((fieldConfig) {
      final answerKey = _answerKeyFor(fieldConfig);
      return DynamicFormField(
        fieldConfig: fieldConfig,
        initialValue: _dynamicAnswers[answerKey],
        onChanged: (value) {
          setState(() {
            _dynamicAnswers[answerKey] = value;
          });
        },
      );
    }).toList();
  }

  String _answerKeyFor(CustomFieldModel fieldConfig) {
    final configuredName = fieldConfig.name.trim();
    if (configuredName.isNotEmpty) return configuredName;

    final normalizedLabel = fieldConfig.label
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(RegExp(r'[^a-z0-9áéíóúüñ]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');

    if (normalizedLabel.contains('categoria') &&
        normalizedLabel.contains('licencia')) {
      return 'categoria_licencia';
    }

    return normalizedLabel.isEmpty ? 'respuesta' : normalizedLabel;
  }
}
