import 'package:flutter/material.dart';
import '../../services/api_client.dart';
import 'package:provider/provider.dart';
import '../../providers/websocket_provider.dart';
import 'consultation_screen.dart';
import '../widgets/date_picker_icon_button.dart';
import '../widgets/custom_card.dart';
import '../widgets/status_chip.dart';
import '../widgets/patient_card_widget.dart';

class CallDetailScreen extends StatefulWidget {
  final Map<String, dynamic> call;

  const CallDetailScreen({super.key, required this.call});

  @override
  State<CallDetailScreen> createState() => _CallDetailScreenState();
}

class _CallDetailScreenState extends State<CallDetailScreen> {
  @override
  void initState() {
    super.initState();
    // НЕ вызываем _loadCallDetails()!
  }

  void _updateCallStatusIfCompleted() async {
    final allCompleted = widget.call['patients'].every(
      (patient) => patient['hasConclusion'] == true,
    );

    if (allCompleted) {
      try {
        final apiClient = Provider.of<ApiClient>(context, listen: false);
        await apiClient.updateEmergencyCallStatus(
          widget.call['id'].toString(),
          'completed',
        );

        // Обновляем кэш
        final webSocketProvider = Provider.of<WebSocketProvider>(
          context,
          listen: false,
        );
        webSocketProvider.updateCallStatus(
          widget.call['id'],
          'Завершён',
        ); // Приватный метод, можно вынести в публичный

        setState(() {
          widget.call['isCompleted'] = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Вызов успешно завершен!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка обновления статуса вызова: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _completeCall() async {
    try {
      final apiClient = Provider.of<ApiClient>(context, listen: false);

      await apiClient.updateEmergencyCallStatus(
        widget.call['id'].toString(),
        'completed',
      );

      // Обновляем кэш
      final webSocketProvider = Provider.of<WebSocketProvider>(
        context,
        listen: false,
      );
      webSocketProvider.updateCallStatus(widget.call['id'], 'Завершён');

      // Закрываем экран и возвращаемся к списку вызовов
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Выезд успешно завершен!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка завершения выезда: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final patients = widget.call['patients'] as List<dynamic>? ?? [];

    final completedCount = patients
        .where((patient) => patient['hasConclusion'] == true)
        .length;
    final totalPatients = patients.length;

    return Scaffold(
      appBar: AppBar(title: Text('Вызов #${widget.call['id']}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Время: ${widget.call['time']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Адрес: ${widget.call['address']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Телефон: ${widget.call['phone']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Пациенты: $completedCount/$totalPatients завершено',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Пациенты:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: patients.length,
                itemBuilder: (context, index) {
                  final patient = patients[index];
                  return _buildPatientCard(patient);
                },
              ),
            ),

            // Кнопка завершения выезда
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Завершить выезд'),
                  onPressed: _completeCall,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> patient) {
    // ✅ Преобразуем widget.call['id'] в int
    int? emergencyCallId;
    final idValue = widget.call['id'];
    if (idValue is String) {
      emergencyCallId = int.tryParse(idValue);
    } else if (idValue is int) {
      emergencyCallId = idValue;
    }

    if (emergencyCallId == null) {
      // Обработка ошибки, если ID не удалось распарсить
      return const Text('Ошибка: ID вызова недействителен');
    }

    return PatientCardWidget(
      patient: patient,
      emergencyCallId: emergencyCallId, // ✅ Передаём int
      onPatientUpdated: () {
        // Можно обновить UI, если нужно
        setState(() {});
      },
      onCallCompleted: _updateCallStatusIfCompleted,
    );
  }
}
