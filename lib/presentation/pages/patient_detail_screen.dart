import 'package:flutter/material.dart';
import '../widgets/section_header.dart';
import '../widgets/info_row.dart';

class PatientDetailScreen extends StatefulWidget {
  final Map<String, dynamic> patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  bool _isEditing = false;
  final Map<String, TextEditingController> _controllers = {};
  
  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _controllers['fullName'] = TextEditingController(
        text: widget.patient['fullName'] ?? '');
    _controllers['gender'] = TextEditingController(
        text: widget.patient['gender'] ?? '');
    _controllers['birthDate'] = TextEditingController(
        text: widget.patient['birthDate'] ?? '');
    _controllers['snils'] = TextEditingController(
        text: widget.patient['snils'] ?? '');
    _controllers['oms'] = TextEditingController(
        text: widget.patient['oms'] ?? '');
    _controllers['passport'] = TextEditingController(
        text: widget.patient['passport'] ?? '');
    _controllers['phone'] = TextEditingController(
        text: widget.patient['phone'] ?? '');
    _controllers['email'] = TextEditingController(
        text: widget.patient['email'] ?? '');
    _controllers['contraindications'] = TextEditingController(
        text: widget.patient['contraindications'] ?? '');
    _controllers['address'] = TextEditingController(
        text: widget.patient['address'] ?? '');
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Медкарта: ${widget.patient['fullName']}'),
        backgroundColor: const Color(0xFF8B8B8B),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _toggleEditMode,
            tooltip: _isEditing ? 'Сохранить изменения' : 'Редактировать',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            SectionHeader(title: 'Основная информация'),
            InfoRow(
              label: 'ФИО',
              value: widget.patient['fullName'] ?? '',
              isEditing: _isEditing,
              controller: _controllers['fullName']!,
              onChanged: (value) => widget.patient['fullName'] = value,
            ),
            InfoRow(
              label: 'Пол',
              value: widget.patient['gender'] ?? '',
              isEditing: _isEditing,
              controller: _controllers['gender']!,
              onChanged: (value) => widget.patient['gender'] = value,
            ),
            InfoRow(
              label: 'Дата рождения',
              value: widget.patient['birthDate'] ?? '',
              isEditing: _isEditing,
              controller: _controllers['birthDate']!,
              onChanged: (value) => widget.patient['birthDate'] = value,
            ),

            SectionHeader(title: 'Документы'),
            InfoRow(
              label: 'СНИЛС',
              value: widget.patient['snils'] ?? '',
              isEditing: _isEditing,
              controller: _controllers['snils']!,
              onChanged: (value) => widget.patient['snils'] = value,
            ),
            InfoRow(
              label: 'Полис ОМС',
              value: widget.patient['oms'] ?? '',
              isEditing: _isEditing,
              controller: _controllers['oms']!,
              onChanged: (value) => widget.patient['oms'] = value,
            ),
            InfoRow(
              label: 'Паспорт',
              value: widget.patient['passport'] ?? '',
              isEditing: _isEditing,
              controller: _controllers['passport']!,
              onChanged: (value) => widget.patient['passport'] = value,
            ),

            SectionHeader(title: 'Контактная информация'),
            InfoRow(
              label: 'Телефон',
              value: widget.patient['phone'] ?? '',
              isEditing: _isEditing,
              controller: _controllers['phone']!,
              onChanged: (value) => widget.patient['phone'] = value,
            ),
            InfoRow(
              label: 'Email',
              value: widget.patient['email'] ?? '',
              isEditing: _isEditing,
              controller: _controllers['email']!,
              onChanged: (value) => widget.patient['email'] = value,
            ),
            InfoRow(
              label: 'Адрес',
              value: widget.patient['address'] ?? '',
              isEditing: _isEditing,
              controller: _controllers['address']!,
              onChanged: (value) => widget.patient['address'] = value,
              maxLines: 2,
            ),

            SectionHeader(title: 'Медицинская информация'),
            InfoRow(
              label: 'Диагноз',
              value: widget.patient['diagnosis'] ?? 'Не указан',
              isEditing: false,
            ),
            InfoRow(
              label: 'Противопоказания',
              value: widget.patient['contraindications'] ?? '',
              isEditing: _isEditing,
              controller: _controllers['contraindications']!,
              onChanged: (value) => widget.patient['contraindications'] = value,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  void _toggleEditMode() {
    if (_isEditing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Изменения сохранены'),
          backgroundColor: Colors.green,
        ),
      );
    }
    
    setState(() {
      _isEditing = !_isEditing;
    });
  }
}