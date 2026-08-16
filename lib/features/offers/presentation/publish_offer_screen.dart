import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/dynamic_form_field.dart';
import '../../../models/job_type_model.dart';
import '../providers/offers_provider.dart';
import '../../contracts_payments/presentation/payment_form_widget.dart';
// import '../../../core/services/upload_service.dart'; // Componente de la Persona 5

class PublishOfferScreen extends StatefulWidget {
  const PublishOfferScreen({super.key});

  @override
  State<PublishOfferScreen> createState() => _PublishOfferScreenState();
}

class _PublishOfferScreenState extends State<PublishOfferScreen> {
  final _formKey = GlobalKey<FormState>();


  final _titleController = TextEditingController();
  final _descController = TextEditingController();


  String? _selectedJobTypeKey;
  String _selectedContractType = 'temporal';
  final Map<String, dynamic> _dynamicAnswers = {};

  String? _uploadedImageUrl;
  String? _paymentId;

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
    super.dispose();
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

    final provider = context.read<OffersProvider>();


    final offerData = {
      'title': _titleController.text.trim(),
      'description': _descController.text.trim(),
      'jobTypeKey': _selectedJobTypeKey,
      'contractType': _selectedContractType,
      'imageUrl': _uploadedImageUrl,
      'paymentId': _paymentId,
      'customFields': _dynamicAnswers,
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
      body: provider.isLoading && provider.jobTypes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título de la Oferta *'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),


              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Descripción *'),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),

              // 3. Tipo de Contrato
              DropdownButtonFormField<String>(
                value: _selectedContractType,
                decoration: const InputDecoration(labelText: 'Tipo de Contrato *'),
                items: const [
                  DropdownMenuItem(value: 'temporal', child: Text('Temporal')),
                  DropdownMenuItem(value: 'fijo', child: Text('Fijo')),
                  DropdownMenuItem(value: 'horas', child: Text('Por Horas')),
                ],
                onChanged: (val) => setState(() => _selectedContractType = val!),
              ),
              const SizedBox(height: 16),

              // 4. Tipo de Empleo
              DropdownButtonFormField<String>(
                value: _selectedJobTypeKey,
                decoration: const InputDecoration(labelText: 'Categoría de Empleo *'),
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
                validator: (v) => v == null ? 'Selecciona una categoría' : null,
              ),
              const SizedBox(height: 16),

              // 5. CAMPOS DINÁMICOS
              if (_selectedJobTypeKey != null) ...[
                const Divider(),
                const Text(
                  'Información Específica',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                    const Text('Foto de la Oferta (Persona 5)'),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.upload),
                      label: const Text('Simular subida de foto'),
                      onPressed: () {
                        // TODO: Llamar al UploadService de la Persona 5
                        setState(() {
                          _uploadedImageUrl = 'https://ejemplo.com/foto.jpg';
                        });
                      },
                    ),
                    if (_uploadedImageUrl != null)
                      const Text('✅ Foto adjuntada', style: TextStyle(color: Colors.green)),
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
                    const Text('Pago de Publicación (Persona 4)'),
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
                      ? const CircularProgressIndicator(color: Colors.white)
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

    final selectedJobType = allJobTypes.firstWhere((jt) => jt.key == _selectedJobTypeKey);

    return selectedJobType.customFields.map((fieldConfig) {
      return DynamicFormField(
        fieldConfig: fieldConfig,
        initialValue: _dynamicAnswers[fieldConfig.name],
        onChanged: (value) {
          setState(() {
            _dynamicAnswers[fieldConfig.name] = value;
          });
        },
      );
    }).toList();
  }
}
