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
    final completedCount = call['patients'].where((p) => p['hasConclusion'] == true).length;
    final totalPatients = call['patients'].length;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: isCompleted 
            ? Colors.green[100] 
            : isEmergency 
                ? const Color(0xFFFFEBEE).withOpacity(0.7) 
                : Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
              
              Row(
                children: [
                  Icon(Icons.person_outline, size: 20, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Пациенты: $completedCount/$totalPatients завершено',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Icon(Icons.local_hospital, size: 20, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Врач: ${call['doctor']}',
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