// pages/patient_history_screen.dart
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kvant_medpuls/services/api_client.dart'; // Убедитесь, что путь к ApiClient правильный

class PatientHistoryScreen extends StatefulWidget {
  final String patientId; // Предполагается, что это ID пациента, но в API, возможно, используется patient_id как строка
  final String patientName;

  const PatientHistoryScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<PatientHistoryScreen> createState() => _PatientHistoryScreenState();
}

class _PatientHistoryScreenState extends State<PatientHistoryScreen> {
  List<Map<String, dynamic>> _visits = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadVisits();
  }

  Future<void> _loadVisits() async {
    final apiClient = Provider.of<ApiClient>(context, listen: false);
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
  
    try {
      final patientId = widget.patientId; // Это строка, например, "25689"
      final response = await apiClient.getPatientReceptionsHistory(patientId);
  
      // ПРОВЕРЯЕМ, ЧТО ОТВЕТ - ЭТО MAP
      if (response is! Map<String, dynamic>) {
        throw Exception('Ответ от API не является Map: ${response.runtimeType}');
      }
  
      // Извлекаем 'data'
      final data = response['data'];
  
      // Проверяем, что data - это Map и содержит 'hits'
      final List<dynamic> hits = data is Map<String, dynamic>
          ? (data['hits'] as List<dynamic>?) ?? [] // Если hits есть и это список, используем его, иначе пустой список
          : [];
  
      final visits = hits.map((reception) {
        // ... (вся остальная логика обработки reception остаётся без изменений)
        final String doctorName = reception['doctor']?.toString() ?? 'Неизвестно';
        final String doctorCode = reception['doctor_code']?.toString() ?? '---';
  
        final List<dynamic> diagnosesList = reception['diagnoses'] ?? [];
        final List<String> diagnosisNames = diagnosesList
            .map((diag) => diag['diagnosisname']?.toString() ?? 'Не указан')
            .toList();
        final String diagnosisText = diagnosisNames.join('\n');
  
        final List<dynamic> servicesList = reception['services'] ?? [];
        final List<String> serviceNames = servicesList
            .map((service) => service['name']?.toString() ?? 'Услуга')
            .toList();
        final String servicesText = serviceNames.join('\n');
  
        final List<dynamic> parametersList = reception['parameters'] ?? [];
        final Map<String, String> parametersMap = {};
        for (var param in parametersList) {
          final name = param['templatename']?.toString() ?? '';
          final value = param['templatevalue']?.toString() ?? '';
          if (name.isNotEmpty) {
            parametersMap[name] = value;
          }
        }
  
        final List<String> parametersLines = parametersMap.entries.map((entry) => '${entry.key}: ${entry.value}').toList();
        final String parametersText = parametersLines.join('\n\n');
  
        return {
          'reception_id': reception['id'] as int?,
          'call_id': reception['call_id']?.toString() ?? '---',
          'doctor_name': doctorName,
          'doctor_code': doctorCode,
          'date': _formatDate(reception['date']?.toString() ?? ''),
          'diagnoses': diagnosisText,
          'services': servicesText,
          'parameters': parametersText,
          'closed': reception['closed'] == true,
          'raw_date': reception['date']?.toString() ?? '',
        };
      }).toList();
  
      setState(() {
        _visits = visits;
        _isLoading = false;
      });
    } on Exception catch (e) {
      setState(() {
        _errorMessage = 'Ошибка загрузки истории: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // Метод для фейкового JSON, ЗАМЕНИТЕ ЕГО НА РЕАЛЬНЫЙ ВЫЗОВ API
  Map<String, dynamic> _getSampleJson() {
    // Это ваш предоставленный JSON, обернутый в {"data": {"hits": [...]}}
    return {
      "data": {
        "hits": [
          {
            "id": 123,
            "patient_id": "CLIENT-001",
            "call_id": "000022256",
            "closed": false,
            "doctor": "Печникова Юлия Владимировна",
            "doctor_code": "00342",
            "date": "2025-11-10T17:38:13Z",
            "diagnoses": [
              {
                "diagnosiscode": "J06.9",
                "diagnosisname": "Острая инфекция верхних дыхательных путей неуточненная"
              },
              {
                "diagnosiscode": "Z54.8",
                "diagnosisname": "Состояние выздоровления после другого лечения"
              }
            ],
            "services": [
              {
                "code": "001М",
                "name": "Консультация  педиатра/терапевта по Москве Будни с 9.00 до 18.00",
                "price": 2450.0,
                "quantity": 1,
                "amount": 2450.0
              }
            ],
            "parameters": [],
            "created_at": "2025-12-01T10:00:00Z",
            "updated_at": "2025-12-01T10:00:00Z"
          },
          {
            "id": 124,
            "patient_id": "CLIENT-001",
            "call_id": "000022036",
            "closed": false,
            "doctor": "Катринец Ирина Васильевна",
            "doctor_code": "00278",
            "date": "2025-11-06T19:01:37Z",
            "diagnoses": [
              {
                "diagnosiscode": "J01.8",
                "diagnosisname": "Острый риносинусит"
              },
              {
                "diagnosiscode": "J35.2",
                "diagnosisname": "Гипертрофия аденоидов"
              }
            ],
            "services": [
              {
                "code": "101.051",
                "name": "Осмотр врача - оториноларинголога первичный",
                "price": 1595.0,
                "quantity": 1,
                "amount": 1595.0
              }
            ],
            "parameters": [
              {
                "templatename": "Пациент:",
                "templatevalue": "Беляев Ярослав Борисович"
              },
              {
                "templatename": "Температура тела",
                "templatevalue": "36.6"
              },
              {
                "templatename": "Состояние пациента",
                "templatevalue": "удовлетворительное"
              },
              {
                "templatename": "Локально",
                "templatevalue": "ЛОР-ОРГАНЫ:\nНОС:     Носовое дыхание        затруднено.В общих носовых ходах  слизистое  отделяемое     скудно   ,носовые раковины   не   увеличены  ,носовая перегородка по срединной линии     .Слизистые     несколько       гиперемированы,рыхлые,корки.\nНосоглотка : осмотрена эндоскопически увеличен аденоид без   признаков    воспаления  ,перекрывает хоаны 1\\3 ,трубные валики обозримы.\nГЛОТКА: Глотание  безболезнено. Слизистая глотки    не    гиперемирована, рыхлая   .Небные миндалины    несколько     увеличены, не  спаяны с дужками  ,рыхлые , крипты   несколько   открыты      . Рубцово не     изменены . Язык обложен несколько.\nГОРТАНЬ: Голос несколько гнусавый .\nУШИ: Ушные раковины, и заушная область – нормальной формы \nAS    Слуховой проход содержит серу   , б\\п серая  ,  утолщена ,  опознавательные  знаки обозримы.\n AD –  слуховой проход свободный      ,б\\п серая утолщена  со всеми опознавательными знаками , четкие.\n  Ш\\Р -AD-3\\5м . AS-3\\5 \n"
              }
            ],
            "created_at": "2025-12-01T10:00:00Z",
            "updated_at": "2025-12-01T10:00:00Z"
          }
        ]
      }
    };
  }


  String _formatDate(String dateString) {
    try {
      // Удаляем временную зону для корректного парсинга
      final cleanedDate = dateString.replaceFirst(RegExp(r'Z$'), '');
      final dateTime = DateTime.parse(cleanedDate);

      // Форматируем дату и время
      final date = '${dateTime.day.toString().padLeft(2, '0')}.'
                   '${dateTime.month.toString().padLeft(2, '0')}.'
                   '${dateTime.year}';

      final time = '${dateTime.hour.toString().padLeft(2, '0')}:'
                   '${dateTime.minute.toString().padLeft(2, '0')}';

      return '$date в $time';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('История посещений: ${widget.patientName}'),
        backgroundColor: const Color(0xFF5F9EA0),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _visits.isEmpty
                  ? const Center(child: Text('История посещений пуста'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _visits.length,
                      itemBuilder: (context, index) {
                        final visit = _visits[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Дата и ID вызова
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      visit['date'] ?? 'Неизвестно',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    Text(
                                      'ID: ${visit['call_id']}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Информация о враче
                                _buildInfoRow(
                                  icon: Icons.person,
                                  title: 'Врач',
                                  content: visit['doctor_name'] ?? 'Неизвестно',
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  icon: Icons.badge,
                                  title: 'Код врача',
                                  content: visit['doctor_code'] ?? '---',
                                ),
                                const SizedBox(height: 12),

                                // Диагнозы
                                _buildInfoRow(
                                  icon: Icons.medical_services,
                                  title: 'Диагнозы',
                                  content: visit['diagnoses'] ?? 'Не указаны',
                                ),
                                const SizedBox(height: 12),

                                // Услуги
                                _buildInfoRow(
                                  icon: Icons.receipt_long,
                                  title: 'Услуги',
                                  content: visit['services'] ?? 'Нет',
                                ),
                                const SizedBox(height: 12),

                                // Параметры (если есть)
                                if ((visit['parameters'] as String?)?.isNotEmpty == true)
                                  _buildInfoRow(
                                    icon: Icons.info,
                                    title: 'Параметры',
                                    content: visit['parameters'],
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  // Вспомогательный виджет для отображения строки с иконкой и заголовком
  Widget _buildInfoRow({required IconData icon, required String title, required String content}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Выравнивание по верхнему краю
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                content,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}