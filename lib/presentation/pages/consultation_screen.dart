// pages/consultation_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_client.dart';
import '../../data/models/dynamic_field_model.dart';

class ConsultationScreen extends StatefulWidget {
  final String patientName;
  final String appointmentType;
  final int recordId;
  final int doctorId;
  final int? emergencyCallId; // Добавляем новый параметр

  const ConsultationScreen({
    super.key,
    required this.patientName,
    required this.appointmentType,
    required this.recordId,
    required this.doctorId,
    this.emergencyCallId, // Делаем необязательным
  });

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final Map<String, dynamic> _formValues = {};
  List<DynamicField> _fields = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _documentType;
  List<Map<String, dynamic>> _medServices = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadConsultationData();
  }

  Future<void> _completeEmergencyConsultation() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, заполните все обязательные поля')),
      );
      return;
    }
  
    try {
      final apiClient = Provider.of<ApiClient>(context, listen: false);
      
      // Формируем данные для отправки
      final specializationData = {
        'document_type': _documentType,
        'fields': _fields.map((field) {
          return {
            'name': field.name,
            'value': _formValues[field.name],
          };
        }).toList(),
      };
  
      // Подготавливаем медицинские услуги
      final medServices = _medServices.map((service) {
        return {
          'id': service['id'],
          'name': service['name'],
          'price': service['price'],
        };
      }).toList();
  
      // Вычисляем итоговую стоимость
      final totalCost = _medServices.fold(0, (sum, service) => sum + (service['price'] as int));
  
      // Создаем заключение
      await apiClient.createEmergencyReception({
        'doctor_id': widget.doctorId,
        'patient_id': widget.recordId,
        'emergency_call_id': widget.emergencyCallId!,
        'diagnosis': _formValues['diagnosis'] ?? '',
        'recommendations': _formValues['recommendations'] ?? '',
        'specialization_data': specializationData,
        'med_services': medServices,
        'total_cost': totalCost, // Добавляем итоговую стоимость
      });
  
      if (!mounted) return;
      Navigator.pop(context, true);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Заключение успешно создано!'),
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

  Future<void> _loadConsultationData() async {
    try {
      final apiClient = Provider.of<ApiClient>(context, listen: false);
      Map<String, dynamic> response;

      if (widget.appointmentType == 'emergency') {
        response = await apiClient.getEmergencyConsultationData(
          widget.emergencyCallId.toString(),
          widget.recordId.toString(),
        );
      } else {
        response = await apiClient.getReceptionDetails(
          widget.doctorId.toString(),
          widget.recordId.toString(),
        );
      }

      final data = response['data'] as Map<String, dynamic>? ?? {};
      final specData = data['specialization_data'] as Map<String, dynamic>? ?? {};

      // Извлекаем медицинские услуги
      final medServices = data['med_services'] as List<dynamic>? ?? [];

      setState(() {
        _documentType = specData['document_type'] as String?;
        final fields = specData['fields'] as List<dynamic>? ?? [];
        _fields = fields.map((f) => DynamicField.fromJson(f)).toList();

        // Сохраняем медицинские услуги
        _medServices = medServices.map((service) {
          return {
            'id': service['id'],
            'name': service['name'],
            'price': service['price'],
          };
        }).toList();

        // Инициализируем значения формы
        for (var field in _fields) {
          _formValues[field.name] = field.value ?? field.defaultValue ?? _getDefaultForType(field.type);
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка загрузки: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  dynamic _getDefaultForType(String type) {
    switch (type) {
      case 'boolean': return false;
      case 'int': return 0;
      case 'array': return [];
      case 'object': return {};
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Консультация: ${widget.patientName}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _buildDynamicForm(),
    );
  }

  Widget _buildMedServicesSection() {
    if (_medServices.isEmpty) {
      return const SizedBox(); // Не отображать если услуг нет
    }

    // Вычисляем итоговую стоимость
    final totalCost = _medServices.fold(0, (sum, service) => sum + (service['price'] as int));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            const Icon(Icons.medical_services, color: Colors.blue),
            const SizedBox(width: 8),
            const Text(
              'Медицинские услуги',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Список услуг
        ..._medServices.map((service) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.medical_information, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        service['name'],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${service['price']} руб.',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),

        // Разделитель
        const Divider(height: 30, thickness: 1.5, color: Colors.grey),

        // Итоговая стоимость
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Общая стоимость:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Text(
                  '$totalCost руб.',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Text(
              'Специализация: ${_documentType ?? 'Неизвестно'}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Динамические поля
            ..._fields.map((field) => _buildField(field)).toList(),

            // Медицинские услуги
            _buildMedServicesSection(),

            // Кнопка сохранения
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _completeConsultation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Завершить консультацию',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(DynamicField field) {
    switch (field.type) {
      case 'string':
        return _buildTextField(field);
      case 'int':
        return _buildNumberField(field);
      case 'boolean':
        return _buildBooleanField(field);
      case 'array':
        return _buildArrayField(field);
      case 'object':
        return _buildObjectField(field);
      default:
        return Text('Неизвестный тип поля: ${field.type}');
    }
  }

  Widget _buildBooleanField(DynamicField field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Switch(
            value: _formValues[field.name] as bool? ?? false,
            onChanged: (value) {
              setState(() {
                _formValues[field.name] = value;
              });
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              field.description,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(DynamicField field) {
    final controller = TextEditingController(
      text: _formValues[field.name]?.toString() ?? '',
    );
  
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.description,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          StatefulBuilder(
            builder: (context, setStateField) {
              return TextFormField(
                controller: controller,
                maxLines: field.format == 'longtext' ? 5 : 1,
                maxLength: field.maxLength,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: field.example != null 
                      ? 'Пример: ${field.example}'
                      : 'Введите ${field.description.toLowerCase()}',
                  filled: true,
                  fillColor: Colors.grey[50],
                  suffixIcon: controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            controller.clear();
                            _formValues[field.name] = '';
                            setStateField(() {});
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  _formValues[field.name] = value;
                  setStateField(() {});
                },
                validator: (value) {
                  if (field.required && (value == null || value.isEmpty)) {
                    return 'Обязательное поле';
                  }
                  if (field.minLength != null && (value?.length ?? 0) < field.minLength!) {
                    return 'Минимум ${field.minLength} символов';
                  }
                  return null;
                },
              );
            },
          ),
          if (field.valueFormat != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                field.valueFormat!,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildNumberField(DynamicField field) {
    final controller = TextEditingController(
      text: _formValues[field.name]?.toString() ?? '',
    );
  
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.description,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          StatefulBuilder(
            builder: (context, setStateField) {
              return TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: field.example != null 
                      ? 'Пример: ${field.example}'
                      : 'Введите ${field.description.toLowerCase()}',
                  filled: true,
                  fillColor: Colors.grey[50],
                  suffixIcon: controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            controller.clear();
                            _formValues[field.name] = 0;
                            setStateField(() {});
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  final numValue = int.tryParse(value);
                  if (numValue != null) {
                    _formValues[field.name] = numValue;
                  } else if (value.isEmpty) {
                    _formValues[field.name] = 0;
                  }
                  setStateField(() {});
                },
                validator: (value) {
                  if (field.required && (value == null || value.isEmpty)) {
                    return 'Обязательное поле';
                  }
                  if (field.minValue != null && (int.tryParse(value ?? '0') ?? 0) < field.minValue!) {
                    return 'Минимальное значение: ${field.minValue}';
                  }
                  return null;
                },
              );
            },
          ),
          if (field.valueFormat != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                field.valueFormat!,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildArrayField(DynamicField field) {
    final items = List<String>.from(_formValues[field.name] ?? []);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.description,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Нет элементов', style: TextStyle(color: Colors.grey)),
            )
          else
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              
              return ListTile(
                title: Text(item),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      items.removeAt(index);
                      _formValues[field.name] = items;
                    });
                  },
                ),
              );
            }).toList(),
          
          const SizedBox(height: 10),
          _buildArrayItemAdder(field, items),
        ],
      ),
    );
  }

  Widget _buildArrayItemAdder(DynamicField field, List<String> items) {
    final controller = TextEditingController();
    
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: 'Новый элемент',
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            if (controller.text.isNotEmpty) {
              setState(() {
                items.add(controller.text);
                _formValues[field.name] = items;
                controller.clear();
              });
            }
          },
          child: const Text('Добавить'),
        ),
      ],
    );
  }

  Widget _buildObjectField(DynamicField field) {
    final Map<String, dynamic> objectData = 
        Map<String, dynamic>.from(_formValues[field.name] ?? {});
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.description,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          
          if (objectData.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Нет элементов', style: TextStyle(color: Colors.grey)),
            )
          else
            ...objectData.entries.map((entry) {
              final key = entry.key;
              final value = entry.value;
              
              return ListTile(
                title: Text('$key: $value'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      objectData.remove(key);
                      _formValues[field.name] = objectData;
                    });
                  },
                ),
              );
            }).toList(),
          
          const SizedBox(height: 10),
          _buildObjectItemAdder(field, objectData),
        ],
      ),
    );
  }

  Widget _buildObjectItemAdder(DynamicField field, Map<String, dynamic> objectData) {
    final keyController = TextEditingController();
    final valueController = TextEditingController();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Добавить элемент:',
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey[700]),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: keyController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: field.keyFormat ?? 'Ключ',
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: valueController,
                keyboardType: field.format == 'map[string]int'
                    ? TextInputType.number
                    : TextInputType.text,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: field.valueFormat ?? 'Значение',
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                final key = keyController.text.trim();
                final value = valueController.text.trim();
                
                if (key.isNotEmpty && value.isNotEmpty) {
                  setState(() {
                    objectData[key] = field.format == 'map[string]int' 
                        ? int.tryParse(value) ?? 0
                        : value;
                    _formValues[field.name] = objectData;
                    keyController.clear();
                    valueController.clear();
                  });
                }
              },
              child: const Text('Добавить'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _completeConsultation() async {
    if (widget.appointmentType == 'emergency') {
      await _completeEmergencyConsultation();
    } else {
      if (!_formKey.currentState!.validate()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пожалуйста, заполните все обязательные поля')),
        );
        return;
      }

      try {
        final apiClient = Provider.of<ApiClient>(context, listen: false);

        // Формируем данные для отправки
        final specializationData = {
          'document_type': _documentType,
          'fields': _fields.map((field) {
            return {
              'name': field.name,
              'value': _formValues[field.name],
            };
          }).toList(),
        };

        await apiClient.updateReceptionHospital(
          widget.recordId.toString(),
          {
            'status': 'completed',
            'specialization_data': specializationData,
          },
        );

        if (!mounted) return;
        Navigator.pop(context, true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Консультация успешно завершена!'),
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
  } 
}