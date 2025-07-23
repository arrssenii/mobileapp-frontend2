// widgets/specialization_forms/ophthalmologist_form.dart
import 'package:flutter/material.dart';
import 'base_form.dart';

class OphthalmologistForm extends StatelessWidget {
  final Map<String, dynamic> formData;

  const OphthalmologistForm({super.key, required this.formData});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: BaseForm(
        title: 'Офтальмологическое заключение',
        child: Column(
          children: [
            buildSectionTitle('Анамнез'),
            buildTextField(
              context: context,
              label: 'Жалобы',
              fieldKey: 'complaints',
              formData: formData,
              maxLines: 2,
            ),
            buildTextField(
              context: context,
              label: 'Системные заболевания',
              fieldKey: 'systemic_diseases',
              formData: formData,
              maxLines: 2,
            ),
            buildTextField(
              context: context,
              label: 'Препараты',
              fieldKey: 'medications',
              formData: formData,
              maxLines: 2,
            ),
            buildTextField(
              context: context,
              label: 'Аллергии',
              fieldKey: 'allergies',
              formData: formData,
            ),
            
            buildSectionTitle('Острота зрения'),
            Row(
              children: [
                Expanded(
                  child: buildTextField(
                    context: context,
                    label: 'Правый глаз (OD)',
                    fieldKey: 'visual_acuity_od',
                    formData: formData,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: buildTextField(
                    context: context,
                    label: 'Левый глаз (OS)',
                    fieldKey: 'visual_acuity_os',
                    formData: formData,
                  ),
                ),
              ],
            ),
            buildTextField(
              context: context,
              label: 'Оба глаза (OU)',
              fieldKey: 'visual_acuity_ou',
              formData: formData,
            ),
            buildTextField(
              context: context,
              label: 'Коррекция',
              fieldKey: 'correction',
              formData: formData,
            ),
            
            buildSectionTitle('Рефракция'),
            Row(
              children: [
                Expanded(
                  child: buildTextField(
                    context: context,
                    label: 'OD (сфера/цилиндр/ось)',
                    fieldKey: 'refraction_od',
                    formData: formData,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: buildTextField(
                    context: context,
                    label: 'OS (сфера/цилиндр/ось)',
                    fieldKey: 'refraction_os',
                    formData: formData,
                  ),
                ),
              ],
            ),
            
            buildSectionTitle('ВГД'),
            Row(
              children: [
                Expanded(
                  child: buildNumberField(
                    context: context,
                    label: 'OD (мм рт.ст.)',
                    fieldKey: 'intraocular_pressure_od',
                    formData: formData,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: buildNumberField(
                    context: context,
                    label: 'OS (мм рт.ст.)',
                    fieldKey: 'intraocular_pressure_os',
                    formData: formData,
                  ),
                ),
              ],
            ),
            
            buildSectionTitle('Передний отрезок'),
            buildTextField(
              context: context,
              label: 'Веки',
              fieldKey: 'lids',
              formData: formData,
            ),
            buildTextField(
              context: context,
              label: 'Конъюнктива',
              fieldKey: 'conjunctiva',
              formData: formData,
            ),
            buildTextField(
              context: context,
              label: 'Роговица',
              fieldKey: 'cornea',
              formData: formData,
            ),
            buildTextField(
              context: context,
              label: 'Передняя камера',
              fieldKey: 'anterior_chamber',
              formData: formData,
            ),
            buildTextField(
              context: context,
              label: 'Радужка',
              fieldKey: 'iris',
              formData: formData,
            ),
            buildTextField(
              context: context,
              label: 'Хрусталик',
              fieldKey: 'lens',
              formData: formData,
            ),
            
            buildSectionTitle('Задний отрезок'),
            buildTextField(
              context: context,
              label: 'Стекловидное тело',
              fieldKey: 'vitreous',
              formData: formData,
            ),
            buildTextField(
              context: context,
              label: 'Диск зрительного нерва',
              fieldKey: 'optic_disc',
              formData: formData,
            ),
            buildTextField(
              context: context,
              label: 'Макула',
              fieldKey: 'macula',
              formData: formData,
            ),
            buildTextField(
              context: context,
              label: 'Сетчатка',
              fieldKey: 'retina',
              formData: formData,
            ),
            buildTextField(
              context: context,
              label: 'Сосуды',
              fieldKey: 'vessels',
              formData: formData,
            ),
            
            buildSectionTitle('Заключение'),
            buildTextField(
              context: context,
              label: 'Диагноз',
              fieldKey: 'diagnosis',
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