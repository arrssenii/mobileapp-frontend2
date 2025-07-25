// pages/patient_history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:demo_app/services/api_client.dart';

class PatientHistoryScreen extends StatefulWidget {
  final int patientId;
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
      final patientId = widget.patientId.toString();
      final response = await apiClient.getPatientReceptionsHistory(patientId);
      
      // Извлекаем список посещений из data.hits
      final List<dynamic> hits = response['data']['hits'] ?? [];
      
      final visits = hits.map((reception) {
        final doctor = reception['doctor'] as Map<String, dynamic>?;
        
        return {
          'date': _formatDate(reception['date']?.toString() ?? ''),
          'doctor': doctor?['full_name']?.toString() ?? 'Неизвестный специалист',
          // Специализация теперь хранится как строка
          'specialization': doctor?['specialization']?.toString() ?? 'Специализация не указана',
          'diagnosis': reception['diagnosis']?.toString() ?? 'Диагноз не указан',
          'recommendations': reception['recommendations']?.toString() ?? 'Рекомендации не указаны',
        };
      }).toList();
  
      setState(() {
        _visits = visits;
        _isLoading = false;
      });
    } on ApiError catch (e) {
      setState(() {
        _errorMessage = 'Ошибка: ${e.message}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  String _formatDate(String dateString) {
    try {
      // Удаляем временную зону для корректного парсинга
      final cleanedDate = dateString.replaceFirst(RegExp(r'\+.*'), '');
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
        backgroundColor: const Color(0xFF8B8B8B),
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
                        return _buildVisitCard(_visits[index]);
                      },
                    ),
    );
  }

  Widget _buildVisitCard(Map<String, dynamic> visit) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Дата
            Text(
              visit['date'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),

            // Информация о враче
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visit['doctor'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        visit['specialization'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Диагноз
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.medical_services, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Диагноз:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      Text(visit['diagnosis']),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Рекомендации
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.receipt, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Рекомендации:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(visit['recommendations']),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}