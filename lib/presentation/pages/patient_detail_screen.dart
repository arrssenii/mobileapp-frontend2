import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_client.dart';
import '../../core/theme/theme_config.dart';
// import 'edit_patient_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  final String patientId;

  const PatientDetailScreen({super.key, required this.patientId});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  late Future<Map<String, dynamic>> _patientFuture;
  bool _isLoading = true;
  Map<String, dynamic>? _patientData;

  @override
  void initState() {
    super.initState();
    _patientFuture = _loadPatient();
  }

  Future<Map<String, dynamic>> _loadPatient() async {
    final apiClient = Provider.of<ApiClient>(context, listen: false);
    try {
      final patientData = await apiClient.getMedCardByPatientId(widget.patientId);
      setState(() {
        _patientData = patientData;
        _isLoading = false;
      });
      return patientData;
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      rethrow;
    }
  }

  // void _openEditScreen() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => EditPatientScreen(
  //         patientId: widget.patientId,
  //         patientData: _patientData!,
  //       ),
  //     ),
  //   ).then((result) {
  //     // Обновляем данные после возвращения с экрана редактирования
  //     if (result == true) {
  //       setState(() {
  //         _isLoading = true;
  //       });
  //       _patientFuture = _loadPatient();
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Карточка пациента'),
        backgroundColor: const Color(0xFF5F9EA0),
        foregroundColor: Colors.white,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.edit),
        //     onPressed: _openEditScreen,
        //     tooltip: 'Редактировать медкарту',
        //   ),
        // ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _patientData == null
              ? const Center(child: Text('Данные пациента не найдены'))
              : _buildPatientInfo(),
    );
  }

  Widget _buildPatientInfo() {
    final patientData = _patientData!;

    // Вспомогательная карточка для одного поля
    Widget _buildFieldCard(String label, String? value) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.textSecondary, // из вашего ThemeExtension
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value ?? 'Не указано',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: context.textPrimary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Карточка для вложенного объекта (врач, полис и т.д.)
    Widget _buildSectionCard(String title, List<Widget> fields) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: context.primaryColor, // акцентный цвет из темы
                ),
              ),
              const SizedBox(height: 14),
              ...fields,
            ],
          ),
        ),
      );
    }

    // Поле внутри секционной карточки
    Widget _buildSectionField(String label, String? value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                '$label:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: context.textSecondary,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                value ?? 'Не указано',
                style: TextStyle(
                  fontSize: 15,
                  color: context.textPrimary,
                  height: 1.3,
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // === Основная информация ===
        _buildFieldCard('Отображаемое имя', patientData['display_name']),
        _buildFieldCard('Дата рождения', patientData['birth_date']),
        _buildFieldCard('Возраст', patientData['age']?.toString()),
        _buildFieldCard('СНИЛС', patientData['snils']),
        _buildFieldCard('Мобильный телефон', patientData['mobile_phone']),
        _buildFieldCard('Дополнительный телефон', patientData['additional_phone']),
        _buildFieldCard('Email', patientData['email']),
        _buildFieldCard('Адрес', patientData['address']),
        _buildFieldCard('Место работы', patientData['workplace']),

        // === Лечащий врач ===
        if (patientData['attending_doctor'] != null)
          _buildSectionCard(
            'Лечащий врач',
            [
              _buildSectionField('ФИО', patientData['attending_doctor']['full_name']),
              _buildSectionField('Клиника', patientData['attending_doctor']['clinic']),
              _buildSectionField('Номер сертификата', patientData['attending_doctor']['policy_or_cert_number']),
              _buildSectionField('Прикрепление', 
                '${patientData['attending_doctor']['attachment_start'] ?? ''} – ${patientData['attending_doctor']['attachment_end'] ?? ''}'
              ),
            ],
          ),

        // === Полис ===
        if (patientData['policy'] != null)
          _buildSectionCard(
            'Полис',
            [
              _buildSectionField('Тип', patientData['policy']['type']),
              _buildSectionField('Номер', patientData['policy']['number']),
            ],
          ),

        // === Сертификат ===
        if (patientData['certificate'] != null)
          _buildSectionCard(
            'Сертификат',
            [
              _buildSectionField('Дата', patientData['certificate']['date']),
              _buildSectionField('Номер', patientData['certificate']['number']),
            ],
          ),

        // === Законный представитель ===
        if (patientData['legal_representative'] != null)
          _buildSectionCard(
            'Законный представитель',
            [
              _buildSectionField('Имя', patientData['legal_representative']['name']),
              _buildSectionField('ID', patientData['legal_representative']['id']?.toString()),
            ],
          ),

        // === Родственник ===
        if (patientData['relative'] != null)
          _buildSectionCard(
            'Родственник',
            [
              _buildSectionField('Имя', patientData['relative']['name']),
              _buildSectionField('Статус', patientData['relative']['status']),
            ],
          ),
      ],
    );
  }

  Widget _buildDoctorSection(Map<String, dynamic> doctor) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Лечащий врач',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('ФИО врача', doctor['full_name'] ?? 'Не указано'),
            _buildInfoRow('Номер сертификата', doctor['policy_or_cert_number'] ?? 'Не указано'),
            _buildInfoRow('Клиника', doctor['clinic'] ?? 'Не указано'),
            _buildInfoRow('Начало прикрепления', doctor['attachment_start'] ?? 'Не указано'),
            _buildInfoRow('Конец прикрепления', doctor['attachment_end'] ?? 'Не указано'),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicySection(Map<String, dynamic> policy) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Полис',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Тип полиса', policy['type'] ?? 'Не указано'),
            _buildInfoRow('Номер полиса', policy['number'] ?? 'Не указано'),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificateSection(Map<String, dynamic> certificate) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Сертификат',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Дата', certificate['date'] ?? 'Не указано'),
            _buildInfoRow('Номер', certificate['number'] ?? 'Не указано'),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalRepresentativeSection(Map<String, dynamic> legalRep) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Законный представитель',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('ID', legalRep['id'] ?? 'Не указано'),
            _buildInfoRow('Имя', legalRep['name'] ?? 'Не указано'),
          ],
        ),
      ),
    );
  }

  Widget _buildRelativeSection(Map<String, dynamic> relative) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Родственник',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Статус', relative['status'] ?? 'Не указано'),
            _buildInfoRow('Имя', relative['name'] ?? 'Не указано'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
