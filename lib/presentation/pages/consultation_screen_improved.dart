
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../services/api_client.dart';
// import '../../data/models/dynamic_field_model.dart';
// import '../widgets/design_system/input_fields.dart';

// class ConsultationScreenImproved extends StatefulWidget {
//   final String patientName;
//   final String appointmentType;
//   final int recordId;
//   final int doctorId;
//   final int? emergencyCallId;
//   final bool isReadOnly;

//   const ConsultationScreenImproved({
//     super.key,
//     required this.patientName,
//     required this.appointmentType,
//     required this.recordId,
//     required this.doctorId,
//     this.emergencyCallId,
//     this.isReadOnly = false,
//   });

//   @override
//   State<ConsultationScreenImproved> createState() => _ConsultationScreenImprovedState();
// }

// class _ConsultationScreenImprovedState extends State<ConsultationScreenImproved> {
//   final Map<String, dynamic> _formValues = {};
//   List<DynamicField> _fields = [];
//   bool _isLoading = true;
//   String? _errorMessage;
//   String? _documentType;
//   String? _documentTypeKey;
//   List<Map<String, dynamic>> _medServices = [];
//   final _formKey = GlobalKey<FormState>();
  
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
//     'urologist_data': [
//       'complaints',
//       'diagnosis',
//       'treatment',
//     ],
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

//   @override
//   void initState() {
//     super.initState();
//     _loadConsultationData();
//   }

//   Future<void> _completeEmergencyConsultation() async {
//     if (!_formKey.currentState!.validate()) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Пожалуйста, заполните все обязательные поля')),
//       );
//       return;
//     }
//     if ((_formValues['diagnosis'] == null || (_formValues['diagnosis'] as String).trim().isEmpty) ||
//       (_formValues['recommendations'] == null || (_formValues['recommendations'] as String).trim().isEmpty)) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Диагноз и рекомендации должны быть заполнены')),
//         );
//         return;
//     }

//     try {
//       final apiClient = Provider.of<ApiClient>(context, listen: false);

//       final Map<String, dynamic> specializationUpdates = {};
//       for (var field in _fields) {
//         specializationUpdates[field.name] = _formValues[field.name];
//       }

//       final totalCost = _medServices.fold(0, (sum, service) => sum + (service['price'] as int));

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

//   Future<void> _loadConsultationData() async {
//     try {
//       final apiClient = Provider.of<ApiClient>(context, listen: false);
//       Map<String, dynamic> response;

//       if (widget.appointmentType == 'emergency') {
//         response = await apiClient.getEmergencyConsultationData(
//           widget.emergencyCallId.toString(),
//           widget.recordId.toString(),
//         );
//       } else {
//         response = await apiClient.getReceptionDetails(
//           widget.doctorId.toString(),
//           widget.recordId.toString(),
//         );
//       }

//       final data = response['data'] as Map<String, dynamic>? ?? {};
    
//       final List<dynamic> medServices = data['med_services'] as List<dynamic>? ?? [];
//       final List<Map<String, dynamic>> medServicesList = medServices.map<Map<String, dynamic>>((service) {
//         return {
//           'id': service['id'] as int,
//           'name': service['name'] as String,
//           'price': service['price'] as int,
//         };
//       }).toList();
  
//       setState(() {
//         final doctor = data['doctor'] as Map<String, dynamic>? ?? {};
//         _documentType = doctor['specialization'] as String? ?? data['specialization'] as String?;
//         final specData = data['specialization_data'] as Map<String, dynamic>? ?? {};
//         _documentTypeKey = specData['document_type'] as String? ?? 'unknown';
//         final fields = specData['fields'] as List<dynamic>? ?? [];
//         _fields = fields.map((f) => DynamicField.fromJson(f as Map<String, dynamic>)).toList();
//         _medServices = medServicesList;

//         for (var field in _fields) {
//             _formValues[field.name] = field.value ?? field.defaultValue ?? _getDefaultForType(field.type);
//         }

//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Ошибка загрузки: ${e.toString()}';
//         _isLoading = false;
//       });
//     }
//   }

//   dynamic _getDefaultForType(String type) {
//     switch (type) {
//       case 'boolean': return false;
//       case 'int': return 0;
//       case 'array': return [];
//       case 'object': return {};
//       default: return '';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Консультация: ${widget.patientName}',
//           style: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         backgroundColor: AppInputTheme.primaryColor,
//         foregroundColor: Colors.white,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _errorMessage != null
//               ? Center(child: Text(_errorMessage!))
//               : _buildDynamicForm(),
//     );
//   }

//   Map<String, List<DynamicField>> splitFields(List<DynamicField> fields, String? documentType) {
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

//     return {
//       'main': mainFields,
//       'additional': additionalFields,
//     };
//   }

//   Widget _buildMedServicesSection() {
//     if (_medServices.isEmpty) {
//       return const SizedBox();
//     }

//     final totalCost = _medServices.fold(0, (sum, service) => sum + (service['price'] as int));

//     return Container(
//       margin: const EdgeInsets.only(top: 24, bottom: 16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: AppInputTheme.borderColor),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Icon(Icons.medical_services, color: AppInputTheme.primaryColor, size: 24),
//               const SizedBox(width: 12),
//               const Text(
//                 'Медицинские услуги',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: AppInputTheme.primaryColor,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),

//           ..._medServices.map((service) {
//             return Container(
//               margin: const EdgeInsets.only(bottom: 12),
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: AppInputTheme.borderColor),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Row(
//                       children: [
//                         const Icon(Icons.medical_information, size: 20, color: AppInputTheme.textSecondary),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Text(
//                             service['name'],
//                             style: const TextStyle(fontSize: 16),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: AppInputTheme.primaryColor.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                     child: Text(
//                       '${service['price']} руб.',
//                       style: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                         color: AppInputTheme.primaryColor,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }).toList(),

//           const SizedBox(height: 16),
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: AppInputTheme.primaryColor),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Общая стоимость:',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   '$totalCost руб.',
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: AppInputTheme.primaryColor,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDynamicForm() {
//     final split = splitFields(_fields, _documentTypeKey);
//     final mainFields = split['main']!;
//     final additionalFields = split['additional']!;

//     return Padding(
//       padding: const EdgeInsets.all(20.0),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Заголовок специализации
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: AppInputTheme.primaryColor.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: AppInputTheme.primaryColor.withOpacity(0.3)),
//               ),
//               child: Text(
//                 'Специализация: ${_documentType ?? 'Неизвестно'}',
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: AppInputTheme.primaryColor,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             const SizedBox(height: 24),

//             // Основной контент
//             Expanded(
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Левая колонка - основные поля
//                   Expanded(
//                     child: _buildFieldsColumn('Основные данные', mainFields),
//                   ),
//                   const SizedBox(width: 20),
//                   // Правая колонка - дополнительные поля
//                   Expanded(
//                     child: _buildFieldsColumn('Дополнительные данные', additionalFields),
//                   ),
//                 ],
//               ),
//             ),

//             // Медицинские услуги
//             _buildMedServicesSection(),

//             // Кнопка завершения
//             if (!widget.isReadOnly)
//               Center(
//                 child: Container(
//                   margin: const EdgeInsets.only(top: 16),
//                   child: ElevatedButton(
//                     onPressed: widget.appointmentType == 'emergency' 
//                         ? _completeEmergencyConsultation
//                         : _completeConsultation,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppInputTheme.successColor,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       elevation: 2,
//                     ),
//                     child: const Text(
//                       'Завершить консультацию',
//                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFieldsColumn(String title, List<DynamicField> fields) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Заголовок колонки
//         Padding(
//           padding: const EdgeInsets.only(bottom: 16.0),
//           child: Text(
//             title,
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: AppInputTheme.textPrimary,
//             ),
//           ),
//         ),

//         // Поля
//         if (fields.isEmpty)
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.grey[50],
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: AppInputTheme.borderColor),
//             ),
//             child: const Center(
//               child: Text(
//                 'Нет полей для отображения',
//                 style: TextStyle(
//                   color: AppInputTheme.textSecondary,
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//           )
//         else
//           Expanded(
//             child: ListView(
//               children: [
//                 ...fields.map((field) => Container(
//                   margin: const EdgeInsets.only(bottom: 16),
//                   child: _buildField(field),
//                 )).toList(),
//               ],
//             ),
//           ),
//       ],
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
//         return Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: Colors.orange[50],
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: Colors.orange),
//           ),
//           child: Text(
//             'Неизвестный тип поля: ${field.type}',
//             style: const TextStyle(color: Colors.orange),
//           ),
//         );
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

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppInputTheme.borderColor),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             field.description,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           Switch(
//             value: currentValue,
//             onChanged: (value) {
//               setState(() {
//                 _formValues[field.name] = value;
//               });
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTextField(DynamicField field) {
//     final value = (_formValues[field.name] ?? _getDefaultForType(field.type)).toString();

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
//         if (field.minLength != null && (value?.length ?? 0) < field.minLength!) {
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
