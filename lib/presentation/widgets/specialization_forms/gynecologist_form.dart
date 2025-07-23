// widgets/specialization_forms/gynecologist_form.dart
import 'package:flutter/material.dart';
import 'base_form.dart';

class GynecologistForm extends StatefulWidget {
  final Map<String, dynamic> formData;

  const GynecologistForm({super.key, required this.formData});

  @override
  State<GynecologistForm> createState() => _GynecologistFormState();
}

class _GynecologistFormState extends State<GynecologistForm> {
  bool _isPregnant = false;

  @override
  void initState() {
    super.initState();
    _isPregnant = widget.formData['is_pregnant'] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: BaseForm(
        title: 'Гинекологическое заключение',
        child: Column(
          children: [
            buildSectionTitle('Анамнез'),
            Row(
              children: [
                Expanded(
                  child: buildNumberField(
                    context: context,
                    label: 'Беременности',
                    fieldKey: 'pregnancies',
                    formData: widget.formData,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: buildNumberField(
                    context: context,
                    label: 'Роды',
                    fieldKey: 'deliveries',
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
                    label: 'Аборты',
                    fieldKey: 'abortions',
                    formData: widget.formData,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: buildTextField(
                    context: context,
                    label: 'Последний мазок',
                    fieldKey: 'last_pap_smear',
                    formData: widget.formData,
                  ),
                ),
              ],
            ),
            
            buildSectionTitle('Текущее состояние'),
            SwitchListTile(
              title: const Text('Беременна'),
              value: _isPregnant,
              onChanged: (value) {
                setState(() {
                  _isPregnant = value;
                  widget.formData['is_pregnant'] = value;
                });
              },
            ),
            if (_isPregnant)
              buildNumberField(
                context: context,
                label: 'Неделя беременности',
                fieldKey: 'pregnancy_week',
                formData: widget.formData,
              ),
            
            buildTextField(
              context: context,
              label: 'Жалобы',
              fieldKey: 'complaints',
              formData: widget.formData,
              maxLines: 2,
            ),
            
            // Остальные поля аналогично...
          ],
        ),
      ),
    );
  }
}