// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../services/api_client.dart';
// import '../../data/models/dynamic_field_model.dart';
// import '../widgets/design_system/input_fields.dart';

// class ConsultationScreen extends StatefulWidget {
//   final String patientName;
//   final String appointmentType;
//   final int recordId;
//   final int doctorId;
//   final int emergencyCallId;
//   final List<dynamic>? templates; // ✅ Новое поле
//   final bool isReadOnly; // ✅ Добавляем поле

//   const ConsultationScreen({
//     super.key,
//     required this.patientName,
//     required this.appointmentType,
//     required this.recordId,
//     required this.doctorId,
//     required this.emergencyCallId,
//     this.templates, // ✅ Необязательное поле
//     this.isReadOnly = false, // ✅ По умолчанию false
//   });

//   @override
//   State<ConsultationScreen> createState() => _ConsultationScreenState();
// }

// class _ConsultationScreenState extends State<ConsultationScreen> {
//   final Map<String, dynamic> _formValues = {};
//   List<DynamicField> _fields = [];
//   String? _documentType;
//   String? _documentTypeKey;
//   List<Map<String, dynamic>> _medServices = [];
//   final _formKey = GlobalKey<FormState>();

//   @override
//   void initState() {
//     super.initState();
//     print('🔍 ConsultationScreen templates: ${widget.templates}');
//     _initializeFormValues();
//   }

//   void _initializeFormValues() {
//     final templates = widget.templates;
//     if (templates != null) {
//       for (final template in templates) {
//         final parameters = template['parameters'] as List<dynamic>?;
//         if (parameters != null) {
//           for (final param in parameters) {
//             final code = param['code'] as String?;
//             final type = param['type'] as String?;
//             if (code != null && type != null) {
//               _formValues[code] = _getDefaultForType(type);
//             }
//           }
//         }
//       }
//     }
//   }

//   static const Map<String, List<String>> mainFieldsMap = {
//     'traumatologist_data': [
//       'injury_type',
//       'localization',
//       'fracture',
//       'dislocation',
//       'sprain',
//       'contusion',
//       'treatment_plan',
//     ],
//     'neurologist_data': [
//       'diagnosis',
//       'complaints',
//       'recommendations',
//       'sensitivity',
//       'gait',
//       'speech',
//     ],
//     'urologist_data': ['complaints', 'diagnosis', 'treatment'],
//     'allergologist_data': [
//       'complaints',
//       'allergen_history',
//       'diagnosis',
//       'recommendations',
//     ],
//     'psychiatrist_data': [
//       'mental_status',
//       'mood',
//       'thought_process',
//       'diagnosis_icd',
//       'therapy_plan',
//     ],
//     'proctologist_data': [
//       'complaints',
//       'digital_examination',
//       'hemorrhoids',
//       'diagnosis',
//       'recommendations',
//     ],
//   };

//   Future<void> _completeEmergencyConsultation() async {
//     if (!_formKey.currentState!.validate()) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Пожалуйста, заполните все обязательные поля'),
//         ),
//       );
//       return;
//     }
//     if ((_formValues['diagnosis'] == null ||
//             (_formValues['diagnosis'] as String).trim().isEmpty) ||
//         (_formValues['recommendations'] == null ||
//             (_formValues['recommendations'] as String).trim().isEmpty)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Диагноз и рекомендации должны быть заполнены'),
//         ),
//       );
//       return;
//     }

//     try {
//       final apiClient = Provider.of<ApiClient>(context, listen: false);

//       final Map<String, dynamic> specializationUpdates = {};
//       for (var field in _fields) {
//         specializationUpdates[field.name] = _formValues[field.name];
//       }

//       final totalCost = _medServices.fold(
//         0,
//         (sum, service) => sum + (service['price'] as int),
//       );

//       await apiClient.updateEmergencyReception(
//         receptionId: widget.recordId,
//         diagnosis: _formValues['diagnosis'] ?? '',
//         recommendations: _formValues['recommendations'] ?? '',
//         specializationUpdates: specializationUpdates,
//         medServices: _medServices,
//         totalCost: totalCost,
//       );

//       if (!mounted) return;
//       Navigator.pop(context, true);

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Заключение успешно обновлено!'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Ошибка сохранения: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   dynamic _getDefaultForType(String type) {
//     switch (type) {
//       case 'boolean':
//         return false;
//       case 'int':
//         return 0;
//       case 'array':
//         return [];
//       case 'object':
//         return {};
//       default:
//         return '';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Консультация: ${widget.patientName}'),
//         backgroundColor: AppInputTheme.primaryColor,
//         foregroundColor: Colors.white,
//       ),
//       body: _buildDynamicForm(), // ✅ Строим форму на основе widget.templates
//     );
//   }

//   // Вспомогательный метод для отображения параметров шаблона
//   List<Widget> _buildTemplateParameters(List<dynamic> parameters) {
//     return parameters.map((param) {
//       // В зависимости от типа параметра (type), отображай разные виды полей ввода
//       // например, TextField для string, Dropdown для list, и т.д.
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 4.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(param['name'] ?? 'Параметр'),
//             // Пример: если type == 'string', то TextField
//             if (param['type'] == 'string')
//               TextField(
//                 decoration: InputDecoration(hintText: param['default'] ?? ''),
//               ),
//             // Добавь другие типы
//           ],
//         ),
//       );
//     }).toList();
//   }

//   Map<String, List<DynamicField>> splitFields(
//     List<DynamicField> fields,
//     String? documentType,
//   ) {
//     final mainFieldNames = mainFieldsMap[documentType] ?? [];

//     final mainFields = <DynamicField>[];
//     final additionalFields = <DynamicField>[];

//     for (var field in fields) {
//       if (mainFieldNames.contains(field.name)) {
//         mainFields.add(field);
//       } else {
//         additionalFields.add(field);
//       }
//     }

//     return {'main': mainFields, 'additional': additionalFields};
//   }

//   Widget _buildMedServicesSection() {
//     if (_medServices.isEmpty) {
//       return const SizedBox();
//     }

//     final totalCost = _medServices.fold(
//       0,
//       (sum, service) => sum + (service['price'] as int),
//     );

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 24),
//         Row(
//           children: [
//             const Icon(
//               Icons.medical_services,
//               color: AppInputTheme.primaryColor,
//             ),
//             const SizedBox(width: 8),
//             const Text(
//               'Медицинские услуги',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: AppInputTheme.primaryColor,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),

//         ..._medServices.map((service) {
//           return Padding(
//             padding: const EdgeInsets.only(bottom: 8.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Row(
//                     children: [
//                       const Icon(
//                         Icons.medical_information,
//                         size: 20,
//                         color: AppInputTheme.textSecondary,
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         service['name'],
//                         style: const TextStyle(fontSize: 16),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Text(
//                   '${service['price']} руб.',
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }).toList(),

//         const Divider(
//           height: 30,
//           thickness: 1.5,
//           color: AppInputTheme.borderColor,
//         ),

//         Padding(
//           padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Общая стоимость:',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 8,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.green[50],
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.green),
//                 ),
//                 child: Text(
//                   '$totalCost руб.',
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.green,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDynamicForm() {
//     final templates = widget.templates; // ✅ Данные из WebSocket

//     if (templates == null || templates.isEmpty) {
//       return const Center(
//         child: Text('Нет доступных шаблонов для этого вызова'),
//       );
//     }

//     return Form(
//       key: _formKey,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView.builder(
//           itemCount: templates.length,
//           itemBuilder: (context, templateIndex) {
//             final template = templates[templateIndex];
//             final parameters = template['parameters'] as List<dynamic>?;

//             return Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       template['templateName'] ?? 'Шаблон',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     if (parameters != null)
//                       ...parameters.map((param) {
//                         final code = param['code'] as String?;
//                         final name = param['name'] as String?;
//                         final type = param['type'] as String?;
//                         final required = param['required'] as bool? ?? false;
//                         final list = param['list'] as List<dynamic>?;

//                         return Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 4.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 '$name${required ? ' *' : ''}',
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                               if (type == 'string')
//                                 TextFormField(
//                                   initialValue: _formValues[code]?.toString(),
//                                   decoration: InputDecoration(
//                                     hintText:
//                                         param['default']?.toString() ?? '',
//                                   ),
//                                   onChanged: (value) {
//                                     if (code != null) {
//                                       // ✅ Проверяем, что code не null
//                                       _formValues[code] = value;
//                                     }
//                                   },
//                                   validator: required && type == 'string'
//                                       ? (value) => value?.trim().isEmpty ?? true
//                                             ? 'Поле обязательно'
//                                             : null
//                                       : null,
//                                 )
//                               else if (type == 'boolean')
//                                 CheckboxListTile(
//                                   title: const Text(''),
//                                   value: _formValues[code] as bool? ?? false,
//                                   onChanged: (value) {
//                                     if (code != null) {
//                                       // ✅ Проверяем, что code не null
//                                       _formValues[code] = value ?? false;
//                                     }
//                                   },
//                                 )
//                               else if (list != null && list.isNotEmpty)
//                                 // Dropdown для выбора из списка
//                                 DropdownButtonFormField<String>(
//                                   value: _formValues[code]?.toString(),
//                                   decoration: const InputDecoration(
//                                     border: OutlineInputBorder(),
//                                   ),
//                                   items: list.map((item) {
//                                     final itemName = item['name'] as String?;
//                                     final itemId = item['id'] as int?;
//                                     return DropdownMenuItem(
//                                       value: itemId?.toString(),
//                                       child: Text(
//                                         itemName ?? '',
//                                       ), // ✅ Используем ?? для itemName
//                                     );
//                                   }).toList(),
//                                   onChanged: (value) {
//                                     if (code != null) {
//                                       // ✅ Проверяем, что code не null
//                                       _formValues[code] = value;
//                                     }
//                                   },
//                                 ),
//                               // Добавь другие типы: int, array, и т.д.
//                             ],
//                           ),
//                         );
//                       }).toList(),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildFieldColumn({
//     required String title,
//     required List<DynamicField> fields,
//     required Color? color,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppInputTheme.borderColor.withOpacity(0.3)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Заголовок колонки
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: AppInputTheme.textPrimary,
//               ),
//             ),
//           ),

//           // Разделитель
//           Container(
//             height: 1,
//             margin: const EdgeInsets.symmetric(horizontal: 16),
//             color: AppInputTheme.borderColor.withOpacity(0.3),
//           ),

//           // Поля
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: ListView.separated(
//                 itemCount: fields.length,
//                 separatorBuilder: (context, index) =>
//                     const SizedBox(height: 16),
//                 itemBuilder: (context, index) => _buildField(fields[index]),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildField(DynamicField field) {
//     switch (field.type) {
//       case 'string':
//       case 'text':
//         return _buildTextField(field);
//       case 'int':
//       case 'number':
//         return _buildNumberField(field);
//       case 'boolean':
//         return _buildBooleanField(field);
//       case 'array':
//         return _buildArrayField(field);
//       case 'object':
//         return _buildObjectField(field);
//       default:
//         return Text('Неизвестный тип поля: ${field.type}');
//     }
//   }

//   Widget _buildBooleanField(DynamicField field) {
//     final currentValue = _formValues[field.name] as bool? ?? false;

//     if (widget.isReadOnly) {
//       return ReadOnlyField(
//         label: field.description,
//         value: currentValue ? 'Да' : 'Нет',
//         isRequired: field.required,
//       );
//     }

//     return ModernSwitchField(
//       label: field.description,
//       value: currentValue,
//       onChanged: (value) {
//         setState(() {
//           _formValues[field.name] = value;
//         });
//       },
//     );
//   }

//   Widget _buildTextField(DynamicField field) {
//     final value = (_formValues[field.name] ?? _getDefaultForType(field.type))
//         .toString();

//     if (widget.isReadOnly) {
//       return ReadOnlyField(
//         label: field.description,
//         value: value,
//         isRequired: field.required,
//       );
//     }

//     return ModernFormField(
//       label: field.description,
//       controller: TextEditingController(text: value),
//       isRequired: field.required,
//       maxLength: field.maxLength,
//       maxLines: field.format == 'longtext' ? 5 : 1,
//       hintText: field.example != null ? 'Пример: ${field.example}' : null,
//       onChanged: (value) {
//         _formValues[field.name] = value;
//       },
//       validator: (value) {
//         if (field.required && (value == null || value.isEmpty)) {
//           return 'Обязательное поле';
//         }
//         if (field.minLength != null &&
//             (value?.length ?? 0) < field.minLength!) {
//           return 'Минимум ${field.minLength} символов';
//         }
//         return null;
//       },
//     );
//   }

//   Widget _buildNumberField(DynamicField field) {
//     final value = _formValues[field.name]?.toString() ?? '';

//     if (widget.isReadOnly) {
//       return ReadOnlyField(
//         label: field.description,
//         value: value,
//         isRequired: field.required,
//       );
//     }

//     return ModernFormField(
//       label: field.description,
//       controller: TextEditingController(text: value),
//       isRequired: field.required,
//       keyboardType: TextInputType.number,
//       maxLength: field.maxLength,
//       hintText: field.example != null ? 'Пример: ${field.example}' : null,
//       onChanged: (value) {
//         _formValues[field.name] = value;
//       },
//       validator: (value) {
//         if (field.required && (value == null || value.isEmpty)) {
//           return 'Обязательное поле';
//         }
//         if (value != null && int.tryParse(value) == null) {
//           return 'Введите число';
//         }
//         return null;
//       },
//     );
//   }

//   Widget _buildArrayField(DynamicField field) {
//     final rawItems = _formValues[field.name] ?? [];
//     final items = (rawItems is List) ? rawItems : [];

//     return Container(
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppInputTheme.borderColor),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Заголовок с иконкой
//           Row(
//             children: [
//               Icon(Icons.list, color: AppInputTheme.primaryColor, size: 20),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   field.description,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: AppInputTheme.textPrimary,
//                   ),
//                 ),
//               ),
//               if (field.required)
//                 const Text(
//                   '*',
//                   style: TextStyle(
//                     color: AppInputTheme.errorColor,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//             ],
//           ),
//           const SizedBox(height: 12),

//           // Список элементов
//           if (items.isEmpty)
//             Container(
//               padding: const EdgeInsets.all(16.0),
//               decoration: BoxDecoration(
//                 color: Colors.grey[50],
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(
//                   color: AppInputTheme.borderColor.withOpacity(0.3),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.info_outline,
//                     color: AppInputTheme.textSecondary,
//                     size: 16,
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     'Нет элементов',
//                     style: TextStyle(
//                       color: AppInputTheme.textSecondary,
//                       fontStyle: FontStyle.italic,
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           else
//             Column(
//               children: items.asMap().entries.map((entry) {
//                 final index = entry.key;
//                 final item = entry.value;

//                 String displayText;
//                 if (item is Map) {
//                   displayText = item.entries
//                       .map((e) => "${e.key}: ${e.value}")
//                       .join(", ");
//                 } else {
//                   displayText = item.toString();
//                 }

//                 return Container(
//                   margin: const EdgeInsets.only(bottom: 8),
//                   padding: const EdgeInsets.all(12.0),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(
//                       color: AppInputTheme.borderColor.withOpacity(0.5),
//                     ),
//                   ),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Container(
//                         width: 24,
//                         height: 24,
//                         decoration: BoxDecoration(
//                           color: AppInputTheme.primaryColor.withOpacity(0.1),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Center(
//                           child: Text(
//                             '${index + 1}',
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                               color: AppInputTheme.primaryColor,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Text(
//                           displayText,
//                           style: const TextStyle(
//                             fontSize: 14,
//                             color: AppInputTheme.textPrimary,
//                           ),
//                         ),
//                       ),
//                       if (!widget.isReadOnly)
//                         IconButton(
//                           icon: Icon(
//                             Icons.delete_outline,
//                             color: AppInputTheme.errorColor,
//                             size: 20,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               items.removeAt(index);
//                               _formValues[field.name] = items;
//                             });
//                           },
//                         ),
//                     ],
//                   ),
//                 );
//               }).toList(),
//             ),

//           const SizedBox(height: 16),
//           if (!widget.isReadOnly)
//             _buildArrayItemAdder(field, items.cast<String>()),
//         ],
//       ),
//     );
//   }

//   Widget _buildArrayItemAdder(DynamicField field, List<String> items) {
//     final controller = TextEditingController();

//     return Container(
//       padding: const EdgeInsets.all(12.0),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: AppInputTheme.borderColor.withOpacity(0.3)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Добавить новый элемент:',
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//               color: AppInputTheme.textSecondary,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   controller: controller,
//                   decoration: InputDecoration(
//                     hintText: 'Введите значение...',
//                     isDense: true,
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 10,
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(6),
//                       borderSide: BorderSide(color: AppInputTheme.borderColor),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(6),
//                       borderSide: BorderSide(color: AppInputTheme.borderColor),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(6),
//                       borderSide: BorderSide(color: AppInputTheme.primaryColor),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               ElevatedButton(
//                 onPressed: () {
//                   final text = controller.text.trim();
//                   if (text.isNotEmpty) {
//                     setState(() {
//                       items.add(text);
//                       _formValues[field.name] = items;
//                       controller.clear();
//                     });
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppInputTheme.primaryColor,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 10,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                 ),
//                 child: const Text('Добавить'),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildObjectField(DynamicField field) {
//     final Map<String, dynamic> objectData = Map<String, dynamic>.from(
//       _formValues[field.name] ?? {},
//     );

//     return Container(
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppInputTheme.borderColor),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Заголовок с иконкой
//           Row(
//             children: [
//               Icon(
//                 Icons.table_chart,
//                 color: AppInputTheme.primaryColor,
//                 size: 20,
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   field.description,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: AppInputTheme.textPrimary,
//                   ),
//                 ),
//               ),
//               if (field.required)
//                 const Text(
//                   '*',
//                   style: TextStyle(
//                     color: AppInputTheme.errorColor,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//             ],
//           ),
//           const SizedBox(height: 12),

//           // Список элементов объекта
//           if (objectData.isEmpty)
//             Container(
//               padding: const EdgeInsets.all(16.0),
//               decoration: BoxDecoration(
//                 color: Colors.grey[50],
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(
//                   color: AppInputTheme.borderColor.withOpacity(0.3),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.info_outline,
//                     color: AppInputTheme.textSecondary,
//                     size: 16,
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     'Нет элементов',
//                     style: TextStyle(
//                       color: AppInputTheme.textSecondary,
//                       fontStyle: FontStyle.italic,
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           else
//             Column(
//               children: objectData.entries.map((entry) {
//                 final key = entry.key;
//                 final value = entry.value;

//                 return Container(
//                   margin: const EdgeInsets.only(bottom: 8),
//                   padding: const EdgeInsets.all(12.0),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(
//                       color: AppInputTheme.borderColor.withOpacity(0.5),
//                     ),
//                   ),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 8,
//                           vertical: 4,
//                         ),
//                         decoration: BoxDecoration(
//                           color: AppInputTheme.primaryColor.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: Text(
//                           key,
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.w600,
//                             color: AppInputTheme.primaryColor,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Text(
//                           value.toString(),
//                           style: const TextStyle(
//                             fontSize: 14,
//                             color: AppInputTheme.textPrimary,
//                           ),
//                         ),
//                       ),
//                       if (!widget.isReadOnly)
//                         IconButton(
//                           icon: Icon(
//                             Icons.delete_outline,
//                             color: AppInputTheme.errorColor,
//                             size: 20,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               objectData.remove(key);
//                               _formValues[field.name] = objectData;
//                             });
//                           },
//                         ),
//                     ],
//                   ),
//                 );
//               }).toList(),
//             ),

//           const SizedBox(height: 16),
//           if (!widget.isReadOnly) _buildObjectItemAdder(field, objectData),
//         ],
//       ),
//     );
//   }

//   Widget _buildObjectItemAdder(
//     DynamicField field,
//     Map<String, dynamic> objectData,
//   ) {
//     if (widget.isReadOnly) return const SizedBox();

//     final keyController = TextEditingController();
//     final valueController = TextEditingController();

//     return Container(
//       padding: const EdgeInsets.all(12.0),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: AppInputTheme.borderColor.withOpacity(0.3)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Добавить новый элемент:',
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//               color: AppInputTheme.textSecondary,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   controller: keyController,
//                   decoration: InputDecoration(
//                     hintText: field.keyFormat ?? 'Ключ',
//                     isDense: true,
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 10,
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(6),
//                       borderSide: BorderSide(color: AppInputTheme.borderColor),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(6),
//                       borderSide: BorderSide(color: AppInputTheme.borderColor),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(6),
//                       borderSide: BorderSide(color: AppInputTheme.primaryColor),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: TextField(
//                   controller: valueController,
//                   keyboardType: field.format == 'map[string]int'
//                       ? TextInputType.number
//                       : TextInputType.text,
//                   decoration: InputDecoration(
//                     hintText: field.valueFormat ?? 'Значение',
//                     isDense: true,
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 10,
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(6),
//                       borderSide: BorderSide(color: AppInputTheme.borderColor),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(6),
//                       borderSide: BorderSide(color: AppInputTheme.borderColor),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(6),
//                       borderSide: BorderSide(color: AppInputTheme.primaryColor),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               ElevatedButton(
//                 onPressed: () {
//                   final key = keyController.text.trim();
//                   final value = valueController.text.trim();

//                   if (key.isNotEmpty && value.isNotEmpty) {
//                     setState(() {
//                       objectData[key] = field.format == 'map[string]int'
//                           ? int.tryParse(value) ?? 0
//                           : value;
//                       _formValues[field.name] = objectData;
//                       keyController.clear();
//                       valueController.clear();
//                     });
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppInputTheme.primaryColor,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 10,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                 ),
//                 child: const Text('Добавить'),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _completeConsultation() async {
//     if (widget.appointmentType == 'emergency') {
//       await _completeEmergencyConsultation();
//     } else {
//       if (!_formKey.currentState!.validate()) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Пожалуйста, заполните все обязательные поля'),
//           ),
//         );
//         return;
//       }

//       try {
//         final apiClient = Provider.of<ApiClient>(context, listen: false);

//         final specializationData = {
//           'document_type': _documentTypeKey,
//           'fields': _fields.map((field) {
//             return {
//               'name': field.name,
//               'type': field.type,
//               'description': field.description,
//               'format': field.format,
//               'min_length': field.minLength,
//               'max_length': field.maxLength,
//               'min_value': field.minValue,
//               'max_value': field.maxValue,
//               'min_items': field.minItems,
//               'max_items': field.maxItems,
//               'example': field.example,
//               'default_value': field.defaultValue,
//               'value': _formValues[field.name],
//               'key_format': field.keyFormat,
//               'value_format': field.valueFormat,
//             };
//           }).toList(),
//         };

//         await apiClient.updateReceptionHospital(widget.recordId.toString(), {
//           'diagnosis': _formValues['diagnosis'] ?? '',
//           'recommendations': _formValues['recommendations'] ?? '',
//           'status': 'completed',
//           'specialization_data': specializationData,
//         });

//         if (!mounted) return;
//         Navigator.pop(context, true);

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Консультация успешно завершена!'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Ошибка сохранения: ${e.toString()}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }
// }
