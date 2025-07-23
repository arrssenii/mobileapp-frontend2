// widgets/specialization_forms/oncologist_form.dart
import 'package:flutter/material.dart';
import 'base_form.dart';

class OncologistForm extends StatelessWidget {
  final Map<String, dynamic> formData;

  const OncologistForm({super.key, required this.formData});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: BaseForm(
        title: 'Онкологическое заключение',
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
              label: 'Факторы риска',
              fieldKey: 'risk_factors',
              formData: formData,
              maxLines: 2,
            ),
            buildTextField(
              context: context,
              label: 'Предыдущие злокачественные заболевания',
              fieldKey: 'previous_malignancies',
              formData: formData,
              maxLines: 2,
            ),
            
            buildSectionTitle('Характеристики опухоли'),
            buildTextField(
              context: context,
              label: 'Локализация',
              fieldKey: 'location',
              formData: formData,
            ),
            buildTextField(
              context: context,
              label: 'Размеры',
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
              label: 'Регионарные лимфоузлы',
              fieldKey: 'regional_lymph_nodes',
              formData: formData,
            ),
            
            buildSectionTitle('Диагностика'),
            buildTextField(
              context: context,
              label: 'Инструментальные исследования',
              fieldKey: 'imaging_studies',
              formData: formData,
              maxLines: 3,
            ),
            buildTextField(
              context: context,
              label: 'Эндоскопия',
              fieldKey: 'endoscopy_results',
              formData: formData,
              maxLines: 2,
            ),
            
            buildSectionTitle('Биопсия'),
            buildTextField(
              context: context,
              label: 'Гистологический тип',
              fieldKey: 'histology',
              formData: formData,
            ),
            buildTextField(
              context: context,
              label: 'Степень дифференцировки',
              fieldKey: 'grade',
              formData: formData,
            ),
            
            buildSectionTitle('Стадирование (TNM)'),
            Row(
              children: [
                Expanded(
                  child: buildTextField(
                    context: context,
                    label: 'T (первичная опухоль)',
                    fieldKey: 't',
                    formData: formData,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: buildTextField(
                    context: context,
                    label: 'N (лимфоузлы)',
                    fieldKey: 'n',
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
                    label: 'M (метастазы)',
                    fieldKey: 'm',
                    formData: formData,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: buildTextField(
                    context: context,
                    label: 'Стадия',
                    fieldKey: 'stage',
                    formData: formData,
                  ),
                ),
              ],
            ),
            buildTextField(
              context: context,
              label: 'Локализация метастазов',
              fieldKey: 'metastatic_sites',
              formData: formData,
              maxLines: 2,
            ),
            
            buildSectionTitle('План лечения'),
            buildTextField(
              context: context,
              label: 'Хирургическое лечение',
              fieldKey: 'surgery',
              formData: formData,
              maxLines: 2,
            ),
            buildTextField(
              context: context,
              label: 'Химиотерапия',
              fieldKey: 'chemotherapy',
              formData: formData,
              maxLines: 2,
            ),
            buildTextField(
              context: context,
              label: 'Лучевая терапия',
              fieldKey: 'radiation',
              formData: formData,
              maxLines: 2,
            ),
            buildTextField(
              context: context,
              label: 'Таргетная терапия',
              fieldKey: 'targeted_therapy',
              formData: formData,
              maxLines: 2,
            ),
            buildTextField(
              context: context,
              label: 'Иммунотерапия',
              fieldKey: 'immunotherapy',
              formData: formData,
              maxLines: 2,
            ),
            buildTextField(
              context: context,
              label: 'Гормонотерапия',
              fieldKey: 'hormonal_therapy',
              formData: formData,
              maxLines: 2,
            ),
            
            buildSectionTitle('Прогноз'),
            buildTextField(
              context: context,
              label: 'Прогноз',
              fieldKey: 'prognosis',
              formData: formData,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}