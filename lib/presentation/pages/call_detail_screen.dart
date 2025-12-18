// lib/presentation/pages/call_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';
import 'consultation_screen.dart';
import '../widgets/date_picker_icon_button.dart';
import '../widgets/custom_card.dart';
import '../widgets/status_chip.dart';
import '../widgets/patient_card_widget.dart';

class CallDetailScreen extends StatefulWidget {
  final int callId;
  final String callTime;
  final String callAddress;
  final String callPhone;
  final String callStatus;
  final List<Map<String, dynamic>> patients; // ✅ Получаем пациентов напрямую

  const CallDetailScreen({
    super.key,
    required this.callId,
    required this.callTime,
    required this.callAddress,
    required this.callPhone,
    required this.callStatus,
    required this.patients,
  });

  @override
  State<CallDetailScreen> createState() => _CallDetailScreenState();
}

class _CallDetailScreenState extends State<CallDetailScreen> {
  // Убрали все ссылки на widget.call, теперь используем widget.callId, widget.patients и т.д.

  @override
  Widget build(BuildContext context) {
    // Используем данные, переданные в конструктор
    final patients = widget.patients;

    // Вычисляем количество завершенных пациентов
    final completedCount = patients
        .where((patient) => patient['hasConclusion'] == true)
        .length;
    final totalPatients = patients.length;

    return Scaffold(
      appBar: AppBar(title: Text('Вызов #${widget.callId}')),
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
                        'Время: ${widget.callTime}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      StatusChip(
                        text: widget.callStatus,
                      ), // Отображение статуса вызова
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Адрес: ${widget.callAddress}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Телефон: ${widget.callPhone}',
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
              child: patients.isEmpty
                  ? const Center(child: Text('Нет пациентов для этого вызова'))
                  : ListView.builder(
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
    // Передаём данные пациента напрямую в PatientCardWidget
    return PatientCardWidget(
      patient: patient,
      emergencyCallId: widget.callId,
      onPatientUpdated: _updateCallStatusIfCompleted,
      onCallCompleted: _updateCallStatusIfCompleted,
    );
  }

  void _updateCallStatusIfCompleted() async {
    // Проверяем, завершены ли все пациенты
    final allCompleted = widget.patients.every(
      (patient) => patient['hasConclusion'] == true,
    );

    if (allCompleted) {
      try {
        final apiClient = Provider.of<ApiClient>(context, listen: false);

        // Обновляем статус вызова на сервере
        await apiClient.updateEmergencyCallStatus(
          widget.callId.toString(),
          'completed',
        );

        // НЕ МЕНЯЕМ widget.patients, потому что он не является частью состояния CallDetailScreen
        // Вместо этого, мы можем просто показать сообщение
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

      // Обновляем статус вызова на сервере
      await apiClient.updateEmergencyCallStatus(
        widget.callId.toString(),
        'completed',
      );

      // Закрываем экран
      Navigator.pop(context, true); // Возвращаем true как сигнал о завершении

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
}
