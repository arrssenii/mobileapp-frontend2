// widgets/specialization_forms/therapist_form.dart
import 'package:flutter/material.dart';
import 'base_form.dart';

class TherapistForm extends StatelessWidget {
  final Map<String, dynamic> formData;

  const TherapistForm({super.key, required this.formData});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: BaseForm(
        title: 'Терапевтическое заключение',
        child: Column(
          children: [
            buildSectionTitle('Основные показатели'),
            Row(
              children: [
                Expanded(
                  child: buildNumberField(
                    context: context,
                    label: 'Температура (°C)',
                    fieldKey: 'temperature',
                    formData: formData,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: buildTextField(
                    context: context,
                    label: 'Давление (мм рт.ст.)',
                    fieldKey: 'blood_pressure',
                    formData: formData,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: buildNumberField(
                    context: context,
                    label: 'Пульс (уд/мин)',
                    fieldKey: 'pulse',
                    formData: formData,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: buildNumberField(
                    context: context,
                    label: 'Дыхание (дых/мин)',
                    fieldKey: 'respiration',
                    formData: formData,
                  ),
                ),
              ],
            ),
            
            buildSectionTitle('Диагностика'),
            buildTextField(
              context: context,
              label: 'Жалобы пациента',
              fieldKey: 'complaints',
              formData: formData,
              maxLines: 3,
            ),
            buildTextField(
              context: context,
              label: 'Диагноз',
              fieldKey: 'diagnosis',
              formData: formData,
              maxLines: 2,
            ),
            
            buildSectionTitle('Рекомендации'),
            buildTextField(
              context: context,
              label: 'Назначения',
              fieldKey: 'recommendations',
              formData: formData,
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }
}