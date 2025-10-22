import 'package:flutter/material.dart';
import 'action_tile.dart';
import '../../core/theme/theme_config.dart';

class PatientOptionsDialog extends StatelessWidget {
  final Map<String, dynamic> patient;
  final VoidCallback onPatientCard;
  final VoidCallback onEmk;

  const PatientOptionsDialog({
    super.key,
    required this.patient,
    required this.onPatientCard,
    required this.onEmk,
  });

  @override
  Widget build(BuildContext context) {
    final fullName = _buildFullName();
    final birthDate = _formatBirthDate(patient['birth_date']);
    final gender = (patient['is_male'] == true || patient['gender'] == true) ? 'Мужчина' : 'Женщина';

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Заголовок с информацией о пациенте
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        (patient['is_male'] == true || patient['gender'] == true)
                            ? Icons.male
                            : Icons.female,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        gender,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        birthDate,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Опции действий
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  ActionTile(
                    icon: Icons.person_outline,
                    title: 'Карточка пациента',
                    iconColor: AppTheme.primaryColor,
                    onTap: () {
                      Navigator.pop(context);
                      onPatientCard();
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1, color: const Color(0xFFF0F0F0)),
                  ),
                  ActionTile(
                    icon: Icons.medical_services_outlined,
                    title: 'ЭМК',
                    iconColor: AppTheme.secondaryColor,
                    onTap: () {
                      Navigator.pop(context);
                      onEmk();
                    },
                  ),
                ],
              ),
            ),

            // Кнопка отмены
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Отмена',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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

  String _buildFullName() {
    final lastName = patient['lastName'] ?? patient['last_name'] ?? '';
    final firstName = patient['firstName'] ?? patient['first_name'] ?? '';
    final middleName = patient['middleName'] ?? patient['middle_name'] ?? '';

    final parts = [lastName, firstName, middleName].where((s) => s.isNotEmpty);
    if (parts.isEmpty) return 'Неизвестный пациент';
    return parts.join(' ');
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
}
