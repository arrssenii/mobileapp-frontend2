import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_client.dart';
import '../../core/theme/theme_config.dart';

// Вспомогательный класс для динамических полей
class DynamicField {
  final String? code;
  final String name;
  final String type;
  final String? defaultVal;
  final bool calculated;
  final String? formula;
  final bool required;
  final List<Map<String, dynamic>> list;

  DynamicField({
    this.code,
    required this.name,
    required this.type,
    this.defaultVal,
    this.calculated = false,
    this.formula,
    this.required = false,
    this.list = const [],
  });
}

class ConsultationScreen extends StatefulWidget {
  final String patientName;
  final String appointmentType;
  final int recordId;
  final int doctorId;
  final int emergencyCallId;
  // ✅ Принимаем шаблоны из WebSocket (но теперь мы их получаем через HTTP)
  final List<Map<String, dynamic>> templatesFromWebSocket;

  const ConsultationScreen({
    super.key,
    required this.patientName,
    required this.appointmentType,
    required this.recordId,
    required this.doctorId,
    required this.emergencyCallId,
    this.templatesFromWebSocket = const [],
  });

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  // ✅ Состояния для шаблонов
  List<Map<String, dynamic>> _templates = [];
  Map<String, dynamic>? _selectedTemplate;
  List<DynamicField> _fields = [];
  Map<String, dynamic> _formValues = {};

  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // ✅ Загружаем шаблоны через HTTP
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiClient = Provider.of<ApiClient>(context, listen: false);

      // ✅ Загружаем шаблоны по кодам
      final templateCodes = widget.templatesFromWebSocket
          .map((template) => template['templateCode'])
          .toList();
      final templatesResponse = await apiClient.getTemplatesByCodes(
        templateCodes as List<String>,
      );
      final templatesData = templatesResponse['data'] as List<dynamic>?;

      if (templatesData == null) {
        throw Exception('Получен некорректный ответ от сервера (шаблоны)');
      }

      setState(() {
        _templates = templatesData.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      setState(() {
        _templates = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка загрузки шаблонов: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ✅ Метод для выбора шаблона
  void _selectTemplate(Map<String, dynamic> template) {
    setState(() {
      _selectedTemplate = template;
      _fields = _parseTemplateParameters(
        template['parameters'] as List<dynamic>? ?? [],
      );
      _formValues = {};
    });
  }

  // ✅ Парсим параметры шаблона в DynamicField
  List<DynamicField> _parseTemplateParameters(List<dynamic> parameters) {
    return parameters.map((param) {
      return DynamicField(
        code: param['code'],
        name: param['name'] ?? 'Параметр',
        type: param['type'] ?? 'string',
        defaultVal: param['default'],
        calculated: param['calculated'] ?? false,
        formula: param['formula'],
        required: param['required'] ?? false,
        list: (param['list'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>(),
      );
    }).toList();
  }

  // ✅ Метод для завершения консультации
  Future<void> _completeConsultation() async {
    if (!(_formKey.currentState?.validate() ?? true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, заполните все обязательные поля'),
        ),
      );
      return;
    }

    try {
      final apiClient = Provider.of<ApiClient>(context, listen: false);

      await apiClient.updateEmergencyReception(
        receptionId: widget.recordId,
        diagnosis: _formValues['diagnosis']?.toString() ?? '',
        recommendations: _formValues['recommendations']?.toString() ?? '',
        specializationUpdates: {}, // или нужные данные
        medServices: [], // или нужные данные
        totalCost: 0, // или нужное значение
        // ... другие поля
      );

      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Заключение успешно обновлено!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка сохранения: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Консультация: ${widget.patientName}'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_selectedTemplate == null) {
      // ✅ Если шаблон не выбран — показываем список шаблонов
      return _buildTemplateSelectionScreen();
    } else {
      // ✅ Если шаблон выбран — показываем форму
      return _buildDynamicForm();
    }
  }

  // ✅ Экран выбора шаблона
  Widget _buildTemplateSelectionScreen() {
    if (_templates.isEmpty) {
      return const Center(child: Text('Нет доступных шаблонов'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Выберите шаблон заключения:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _templates.length,
              itemBuilder: (context, index) {
                final template = _templates[index];
                return Card(
                  child: ListTile(
                    title: Text(
                      template['templateName'] ?? 'Шаблон ${index + 1}',
                    ),
                    subtitle: Text(
                      template['specialization'] ?? 'Специализация не указана',
                    ),
                    onTap: () => _selectTemplate(template),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Динамическая форма на основе полей шаблона
  Widget _buildDynamicForm() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Шаблон: ${_selectedTemplate?['templateName'] ?? 'Неизвестный'}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: _fields
                    .map((field) => _buildFieldWidget(field))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _completeConsultation,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Завершить консультацию'),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Виджет для отображения поля ввода
  Widget _buildFieldWidget(DynamicField field) {
    // Пропускаем вычисляемые поля
    if (field.calculated) return Container();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${field.name}${field.required ? ' *' : ''}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          if (field.type == 'string')
            TextFormField(
              initialValue: field.defaultVal,
              decoration: InputDecoration(
                hintText: field.defaultVal ?? '',
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                _formValues[field.code ?? field.name] = value;
              },
              validator: field.required
                  ? (value) => (value?.trim().isEmpty ?? true)
                        ? 'Поле обязательно'
                        : null
                  : null,
            )
          else if (field.type == 'number')
            TextFormField(
              initialValue: field.defaultVal,
              decoration: InputDecoration(
                hintText: field.defaultVal ?? '',
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _formValues[field.code ?? field.name] = value;
              },
              validator: field.required
                  ? (value) {
                      if (value == null || value.isEmpty) {
                        return 'Поле обязательно';
                      }
                      final number = double.tryParse(value);
                      if (number == null) {
                        return 'Введите число';
                      }
                      return null;
                    }
                  : null,
            )
          else if (field.type == 'date')
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Выберите дату',
                border: const OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  _formValues[field.code ?? field.name] = date
                      .toIso8601String();
                }
              },
            )
          else if (field.type == 'boolean')
            Row(
              children: [
                Checkbox(
                  value: _formValues[field.code ?? field.name] == true,
                  onChanged: (value) {
                    _formValues[field.code ?? field.name] = value;
                  },
                ),
                Expanded(child: Text(field.name)),
              ],
            )
          else if (field.type == 'select' || field.list.isNotEmpty)
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(border: OutlineInputBorder()),
              value: _formValues[field.code ?? field.name]?.toString(),
              items: field.list.map((item) {
                return DropdownMenuItem(
                  value: item['name']?.toString(),
                  child: Text(item['name']?.toString() ?? ''),
                );
              }).toList(),
              onChanged: (value) {
                _formValues[field.code ?? field.name] = value;
              },
              validator: field.required
                  ? (value) => value == null ? 'Поле обязательно' : null
                  : null,
            )
          else
            TextFormField(
              initialValue: field.defaultVal,
              decoration: InputDecoration(
                hintText: field.defaultVal ?? '',
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                _formValues[field.code ?? field.name] = value;
              },
            ),
        ],
      ),
    );
  }
}
