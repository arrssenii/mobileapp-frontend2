import 'package:flutter/material.dart';
import 'action_tile.dart';

class CallOptionDialog extends StatelessWidget {
  final Map<String, dynamic> call;
  final bool isCompleted;
  final VoidCallback onAccept;
  final VoidCallback onDetails;
  final VoidCallback onPatient;
  final VoidCallback onCancel;

  const CallOptionDialog({
    super.key,
    required this.call,
    required this.isCompleted,
    required this.onAccept,
    required this.onDetails,
    required this.onPatient,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 0,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ActionTile(
                icon: Icons.medical_services,
                title: 'Принять вызов',
                onTap: onAccept,
              ),
              ActionTile(
                icon: Icons.info_outline,
                title: 'Детали вызова',
                onTap: onDetails,
              ),
              ActionTile(
                icon: Icons.person,
                title: 'Карта пациента',
                onTap: onPatient,
              ),
              if (!isCompleted)
                ActionTile(
                  icon: Icons.close,
                  title: 'Отменить вызов',
                  onTap: onCancel,
                ),
              const SizedBox(height: 8),
              TextButton(
                child: const Text('Закрыть', 
                  style: TextStyle(
                    color: Color(0xFF8B8B8B),
                    fontSize: 16,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}