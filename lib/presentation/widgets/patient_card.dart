import 'package:flutter/material.dart';
import 'custom_card.dart';
import 'action_tile.dart';
import 'patient_options_dialog.dart';

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
    return InkWell(
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          _buildFullName(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow(
                    (patient['is_male'] == true || patient['gender'] == true) ? Icons.male : Icons.female,
                    (patient['is_male'] == true || patient['gender'] == true) ? 'Мужчина' : 'Женщина',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.calendar_today,
                    _formatBirthDate(patient['birth_date']),
                  ),
                ],
              ),
            ),
          ),
          if (showStatusIndicator)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _buildFullName() {
    final lastName = patient['lastName'] ?? patient['last_name'] ?? '';
    final firstName = patient['firstName'] ?? patient['first_name'] ?? '';
    final middleName = patient['middleName'] ?? patient['middle_name'] ?? '';

    final parts = [lastName, firstName, middleName].where((s) => s.isNotEmpty);
    if (parts.isEmpty) return 'Неизвестный пациент';
    return parts.join(' ');
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF8B8B8B)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatBirthDate(dynamic birthDate) {
    if (birthDate == null) return 'Дата рождения неизвестна';

    try {
      final date = DateTime.parse(birthDate);
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year;
      return '$day.$month.$year';
    } catch (_) {
      return 'Неверный формат даты';
    }
  }

  void _showOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => PatientOptionsDialog(
        patient: patient,
        onPatientCard: () {
          if (context.mounted) {
            onDetails();
          }
        },
        onEmk: () {
          if (context.mounted) {
            onHistory();
          }
        },
      ),
    );
  }
}
