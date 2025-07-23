// widgets/specialization_forms/cardiologist_form.dart
import 'package:flutter/material.dart';
import 'base_form.dart';

class CardiologistForm extends StatefulWidget {
  final Map<String, dynamic> formData;

  const CardiologistForm({super.key, required this.formData});

  @override
  State<CardiologistForm> createState() => _CardiologistFormState();
}

class _CardiologistFormState extends State<CardiologistForm> {
  final List<String> _selectedRiskFactors = [];
  final List<String> _riskFactors = [
    'Курение', 
    'Диабет', 
    'Ожирение',
    'Гипертония',
    'Наследственность',
    'Малоподвижность'
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: BaseForm(
        title: 'Кардиологическое заключение',
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
            
            buildSectionTitle('Факторы риска'),
            Wrap(
              spacing: 8,
              children: _riskFactors.map((factor) {
                final isSelected = _selectedRiskFactors.contains(factor);
                return FilterChip(
                  label: Text(factor),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedRiskFactors.add(factor);
                      } else {
                        _selectedRiskFactors.remove(factor);
                      }
                      widget.formData['risk_factors'] = _selectedRiskFactors;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            
            buildSectionTitle('Физикальное обследование'),
            Row(
              children: [
                Expanded(
                  child: buildTextField(
                    context: context,
                    label: 'Давление (мм рт.ст.)',
                    fieldKey: 'blood_pressure',
                    formData: widget.formData,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: buildNumberField(
                    context: context,
                    label: 'ЧСС (уд/мин)',
                    fieldKey: 'heart_rate',
                    formData: widget.formData,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: buildNumberField(
                    context: context,
                    label: 'ЧДД (дых/мин)',
                    fieldKey: 'respiratory_rate',
                    formData: widget.formData,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: buildTextField(
                    context: context,
                    label: 'Аускультация сердца',
                    fieldKey: 'heart_auscultation',
                    formData: widget.formData,
                  ),
                ),
              ],
            ),
            buildTextField(
              context: context,
              label: 'Отеки',
              fieldKey: 'edema',
              formData: widget.formData,
            ),
            buildTextField(
              context: context,
              label: 'Пульс',
              fieldKey: 'pulse_examination',
              formData: widget.formData,
            ),
            
            buildSectionTitle('Диагностика'),
            buildTextField(
              context: context,
              label: 'ЭКГ',
              fieldKey: 'ecg',
              formData: widget.formData,
              maxLines: 3,
            ),
            buildTextField(
              context: context,
              label: 'Нагрузочный тест',
              fieldKey: 'stress_test',
              formData: widget.formData,
              maxLines: 2,
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