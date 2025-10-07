import 'package:flutter/material.dart';
import 'package:demo_app/data/models/appointment_model.dart'; // Добавлен импорт модели
import 'package:intl/intl.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onTap;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color? cardColor;
    IconData? statusIcon;
    Color? iconColor;
    String statusText = '';

    switch (appointment.status) {
      case AppointmentStatus.noShow:
        cardColor = Colors.red.shade100;
        statusIcon = Icons.close;
        iconColor = Colors.red;
        statusText = 'Отменён';
        break;
      case AppointmentStatus.completed:
        cardColor = Colors.green.shade100;
        statusIcon = Icons.check;
        iconColor = Colors.green;
        statusText = 'Приём завершён';
        break;
      case AppointmentStatus.scheduled:
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: cardColor,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              Row(
                children: [
                  Container(
                    width: 80,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${appointment.time.hour}:${appointment.time.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${appointment.time.hour + 1}:${appointment.time.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const VerticalDivider(width: 20, thickness: 1),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              appointment.patientName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold, 
                                fontSize: 16
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${appointment.isMale ? 'М' : 'Ж'})',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${DateFormat('dd.MM.yyyy').format(appointment.birthDate)}',
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appointment.diagnosis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (appointment.status != AppointmentStatus.scheduled)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: [
                      Icon(statusIcon, color: iconColor, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: iconColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}