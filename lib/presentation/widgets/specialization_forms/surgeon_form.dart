// widgets/specialization_forms/surgeon_form.dart
import 'package:flutter/material.dart';
import 'base_form.dart';

class SurgeonForm extends StatefulWidget {
  final Map<String, dynamic> formData;

  const SurgeonForm({super.key, required this.formData});

  @override
  State<SurgeonForm> createState() => _SurgeonFormState();
}

class _SurgeonFormState extends State<SurgeonForm> {
  final List<String> _selectedSymptoms = [];
  final List<String> _symptoms = [
    'Щеткина-Блюмберга',
    'Воскресенского',
    'Ровзинга',
    'Ситковского',
    'Образцова'
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: BaseForm(
        title: 'Хирургическое заключение',
        child: Column(
          children: [
            buildSectionTitle('Анамнез'),
            buildTextField(
              context: context,
              label: 'Жалобы',
              fieldKey: 'complaints',
              formData: widget.formData,
              maxLines: 3,
            ),
            buildTextField(
              context: context,
              label: 'Сопутствующие заболевания',
              fieldKey: 'chronic_conditions',
              formData: widget.formData,
              maxLines: 2,
            ),
            
            buildSectionTitle('Обследование'),
            buildTextField(
              context: context,
              label: 'Общее состояние',
              fieldKey: 'general_condition',
              formData: widget.formData,
            ),
            buildNumberField(
              context: context,
              label: 'Температура (°C)',
              fieldKey: 'body_temperature',
              formData: widget.formData,
            ),
            buildTextField(
              context: context,
              label: 'Перкуссия',
              fieldKey: 'percussion',
              formData: widget.formData,
            ),
            
            buildSectionTitle('Перитонеальные симптомы'),
            Wrap(
              spacing: 8,
              children: _symptoms.map((symptom) {
                final isSelected = _selectedSymptoms.contains(symptom);
                return FilterChip(
                  label: Text(symptom),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedSymptoms.add(symptom);
                      } else {
                        _selectedSymptoms.remove(symptom);
                      }
                      widget.formData['peritoneal_symptoms'] = _selectedSymptoms;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            
            buildTextField(
              context: context,
              label: 'Обследование на грыжи',
              fieldKey: 'hernia_examination',
              formData: widget.formData,
            ),
            
            buildSectionTitle('Диагностика'),
            buildTextField(
              context: context,
              label: 'Инструментальные исследования',
              fieldKey: 'imaging_studies',
              formData: widget.formData,
              maxLines: 3,
            ),
            buildTextField(
              context: context,
              label: 'Анализы крови',
              fieldKey: 'blood_tests',
              formData: widget.formData,
              maxLines: 2,
            ),
            buildTextField(
              context: context,
              label: 'Анализ мочи',
              fieldKey: 'urine_tests',
              formData: widget.formData,
            ),
            
            buildSectionTitle('Операция'),
            buildTextField(
              context: context,
              label: 'Выполненная операция',
              fieldKey: 'operation_performed',
              formData: widget.formData,
            ),
            buildTextField(
              context: context,
              label: 'Тип операции',
              fieldKey: 'operation_type',
              formData: widget.formData,
            ),
            buildTextField(
              context: context,
              label: 'Вид анестезии',
              fieldKey: 'anesthesia_type',
              formData: widget.formData,
            ),
            
            buildSectionTitle('Заключение'),
            buildTextField(
              context: context,
              label: 'Диагноз',
              fieldKey: 'diagnosis',
              formData: widget.formData,
              maxLines: 2,
            ),
            buildTextField(
              context: context,
              label: 'Осложнения',
              fieldKey: 'complications',
              formData: widget.formData,
              maxLines: 2,
            ),
            buildTextField(
              context: context,
              label: 'Рекомендации',
              fieldKey: 'recommendations',
              formData: widget.formData,
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }
}