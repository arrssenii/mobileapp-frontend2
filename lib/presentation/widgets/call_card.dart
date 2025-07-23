import 'package:flutter/material.dart';
import '../widgets/status_chip.dart';

class CallCard extends StatelessWidget {
  final Map<String, dynamic> call;
  final VoidCallback onTap;

  const CallCard({
    super.key,
    required this.call,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEmergency = call['status'] == 'ЭКСТРЕННЫЙ';
    final isCompleted = call['isCompleted'];
    final patients = call['patients'] as List<dynamic>;
    final completedCount = patients.where((p) => p['hasConclusion'] == true).length;
    final totalPatients = patients.length;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        // ... стили без изменений
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusChip(
                    text: call['status'],
                    isEmergency: isEmergency,
                  ),
                  Text(
                    call['time'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Text(
                '${call['address']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Заменяем имя пациента на телефон
              Row(
                children: [
                  Icon(Icons.phone, size: 20, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Телефон: ${call['phone']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Отображаем статус завершения пациентов
              Row(
                children: [
                  Icon(Icons.people_outline, size: 20, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Пациенты: $completedCount/$totalPatients завершено',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}