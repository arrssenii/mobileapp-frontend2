import 'package:flutter/material.dart';
import 'custom_card.dart';
import 'action_tile.dart';

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
                          patient['full_name'] ?? 'Неизвестный пациент', // исправлено
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Убрали иконку критичности (нет данных)
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Исправленный блок с данными - вертикальное расположение
                  _buildInfoRow(
                    patient['is_male'] == true 
                        ? Icons.male 
                        : Icons.female,
                    patient['is_male'] ? 'Мужчина' : 'Женщина', // добавлено
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.calendar_today,
                    _formatBirthDate(patient['birth_date']), // форматирование даты
                  ),
                  // Убрали блок с диагнозом (нет данных)
                ],
              ),
            ),
          ),
          // Убрали индикатор статуса (нет данных)
        ],
      ),
    );
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
      return '${date.day}.${date.month}.${date.year}';
    } catch (e) {
      return 'Неверный формат даты';
    }
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