import 'package:flutter/material.dart';
import '../widgets/custom_card.dart';
import '../widgets/action_tile.dart';

class PatientCard extends StatelessWidget {
  final Map<String, dynamic> patient;
  final VoidCallback onDetails;
  final VoidCallback onHistory;
  final bool isSelectable;
  final bool showStatusIndicator;
  final Color? backgroundColor;
  final bool isSelected;

  const PatientCard({
    super.key,
    required this.patient,
    required this.onDetails,
    required this.onHistory,
    this.isSelectable = true,
    this.showStatusIndicator = false,
    this.backgroundColor,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell( // <-- Добавлено
      borderRadius: BorderRadius.circular(12),
      onTap: isSelectable ? () => _showOptions(context) : null,
      child: Stack(
        children: [
          CustomCard(
          backgroundColor: isSelected 
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : backgroundColor ?? Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        patient['fullName'] ?? 'Неизвестный пациент',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (patient['isCritical'] == true)
                      const Icon(Icons.warning, color: Colors.red),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildInfoRow(Icons.bed, patient['room'] ?? 'Палата не указана'),
                    const SizedBox(width: 20),
                    _buildInfoRow(
                      Icons.medical_services, 
                      patient['diagnosis'] ?? 'Диагноз не указан'
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (showStatusIndicator && patient['status'] != null)
          Positioned(
            top: 8,
            right: 8,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getStatusColor(patient['status']),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'critical':
        return Colors.red;
      case 'stable':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF8B8B8B)),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ActionTile(
              icon: Icons.visibility,
              title: 'Подробнее',
              onTap: () {
                Navigator.pop(context);
                onDetails();
              },
            ),
            ActionTile(
              icon: Icons.history,
              title: 'История болезни',
              onTap: () {
                Navigator.pop(context);
                onHistory();
              },
            ),
          ],
        ),
      ),
    );
  }
}