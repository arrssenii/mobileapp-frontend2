// widgets/specialization_forms/endocrinologist_form.dart
import 'package:flutter/material.dart';
import 'base_form.dart';

class EndocrinologistForm extends StatelessWidget {
  final Map<String, dynamic> formData;

  const EndocrinologistForm({super.key, required this.formData});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: BaseForm(
        title: 'Эндокринологическое заключение',
        child: Column(
          children: [
            buildSectionTitle('Анамнез'),
            buildTextField(
              context: context,
              label: 'Жалобы',
              fieldKey: 'complaints',
              formData: formData,
              maxLines: 3,
            ),
            buildTextField(
              context: context,
              label: 'Длительность заболевания',
              fieldKey: 'duration',
              formData: formData,
            ),
            buildTextField(
              context: context,
              label: 'Прогрессирование симптомов',
              fieldKey: 'progression',
              formData: formData,
              maxLines: 2,
            ),
            
            buildSectionTitle('Антропометрия'),
            Row(
              children: [
                Expanded(
                  child: buildNumberField(
                    context: context,
                    label: 'Рост (см)',
                    fieldKey: 'height',
                    formData: formData,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: buildNumberField(
                    context: context,
                    label: 'Вес (кг)',
                    fieldKey: 'weight',
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
                    label: 'ИМТ',
                    fieldKey: 'bmi',
                    formData: formData,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: buildNumberField(
                    context: context,
                    label: 'Окружность талии (см)',
                    fieldKey: 'waist_circ',
                    formData: formData,
                  ),
                ),
              ],
            ),
            buildNumberField(
              context: context,
              label: 'Окружность шеи (см)',
              fieldKey: 'neck_circ',
              formData: formData,
            ),
            
            buildSectionTitle('Щитовидная железа'),
            buildTextField(
              context: context,
              label: 'Размер',
              fieldKey: 'size',
              formData: formData,
            ),
            buildTextField(
              context: context,
              label: 'Консистенция',
              fieldKey: 'consistency',
              formData: formData,
            ),
            buildTextField(
              context: context,
              label: 'Подвижность',
              fieldKey: 'mobility',
              formData: formData,
            ),
            buildTextField(
              context: context,
              label: 'Узлы',
              fieldKey: 'nodules',
              formData: formData,
            ),
            buildTextField(
              context: context,
              label: 'Болезненность',
              fieldKey: 'tenderness',
              formData: formData,
            ),
            
            buildSectionTitle('Углеводный обмен'),
            Row(
              children: [
                Expanded(
                  child: buildNumberField(
                    context: context,
                    label: 'Глюкоза натощак (ммоль/л)',
                    fieldKey: 'fasting_glucose',
                    formData: formData,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: buildNumberField(
                    context: context,
                    label: 'HbA1c (%)',
                    fieldKey: 'hbA1c',
                    formData: formData,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: buildTextField(
                    context: context,
                    label: 'Глюкозотолерантный тест',
                    fieldKey: 'ogtt',
                    formData: formData,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: buildNumberField(
                    context: context,
                    label: 'Инсулин (мкЕд/мл)',
                    fieldKey: 'insulin',
                    formData: formData,
                  ),
                ),
              ],
            ),
            buildNumberField(
              context: context,
              label: 'С-пептид (нг/мл)',
              fieldKey: 'c_peptide',
              formData: formData,
            ),
            
            buildSectionTitle('Инструментальные исследования'),
            buildTextField(
              context: context,
              label: 'УЗИ щитовидной железы',
              fieldKey: 'thyroid_usg',
              formData: formData,
              maxLines: 3,
            ),
            
            buildSectionTitle('Заключение'),
            buildTextField(
              context: context,
              label: 'Диагноз щитовидной железы',
              fieldKey: 'thyroid_diagnosis',
              formData: formData,
              maxLines: 2,
            ),
            buildTextField(
              context: context,
              label: 'Осложнения',
              fieldKey: 'complications',
              formData: formData,
              maxLines: 2,
            ),
            buildTextField(
              context: context,
              label: 'Рекомендации',
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