import 'package:flutter/material.dart';
import '../widgets/specialization_forms/cardiologist_form.dart';
import '../widgets/specialization_forms/endocrinologist_form.dart';
import '../widgets/specialization_forms/gynecologist_form.dart';
import '../widgets/specialization_forms/oncologist_form.dart';
import '../widgets/specialization_forms/ophthalmologist_form.dart';
import '../widgets/specialization_forms/surgeon_form.dart';
import '../widgets/specialization_forms/therapist_form.dart';
import '../../services/api_client.dart';
import '../../core/utils/specialization_helper.dart';
import 'package:provider/provider.dart';

class ConsultationScreen extends StatefulWidget {
  final String patientName;
  final String appointmentType;
  final int recordId;
  final String specialization; // Добавлено

  const ConsultationScreen({
    super.key,
    required this.patientName,
    required this.appointmentType,
    required this.recordId,
    required this.specialization, // Добавлено
  });

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final Map<String, dynamic> _formData = {};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Консультация: ${widget.patientName}'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Заголовок пациента и специализации
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.patientName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.specialization,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            
            // Разделитель
            const Divider(height: 1, thickness: 1),
            
            // Основная форма с прокруткой
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildSpecializationForm(),
              ),
            ),
            
            // Кнопка завершения
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Center(
                child: ElevatedButton(
                  onPressed: _completeConsultation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Завершить консультацию',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecializationForm() {
    final normalizedSpec = SpecializationHelper.normalize(widget.specialization);
    
    switch (normalizedSpec) {
      case 'Гинеколог':
        return GynecologistForm(formData: _formData);
      case 'Кардиолог':
        return CardiologistForm(formData: _formData);
      case 'Хирург':
        return SurgeonForm(formData: _formData);
      case 'Офтальмолог':
        return OphthalmologistForm(formData: _formData);
      case 'Онколог':
        return OncologistForm(formData: _formData);
      case 'Эндокринолог':
        return EndocrinologistForm(formData: _formData);
      case 'Терапевт':
      default:
        return TherapistForm(formData: _formData);
    }
  }

  void _completeConsultation() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      try {
        final apiClient = Provider.of<ApiClient>(context, listen: false);
        await apiClient.updateReceptionHospital(
          widget.recordId.toString(),
          {
            'status': 'completed',
            'diagnosis': _formData['diagnosis'] ?? '',
            'recommendations': _formData['recommendations'] ?? '',
            'specialization_data': _formData,
          },
        );

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка сохранения: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}