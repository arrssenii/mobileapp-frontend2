import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_client.dart';
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
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          _buildInfoCard('Отображаемое имя', patientData['display_name'] ?? 'Не указано'),
          const SizedBox(height: 12),
          _buildInfoCard('Мобильный телефон', patientData['mobile_phone'] ?? 'Не указано'),
          const SizedBox(height: 12),
          _buildInfoCard('Дополнительный телефон', patientData['additional_phone'] ?? 'Не указано'),
          const SizedBox(height: 12),
          _buildInfoCard('Email', patientData['email'] ?? 'Не указано'),
          const SizedBox(height: 12),
          _buildInfoCard('Адрес', patientData['address'] ?? 'Не указано'),
          const SizedBox(height: 12),
          _buildInfoCard('СНИЛС', patientData['snils'] ?? 'Не указано'),
          const SizedBox(height: 12),
          _buildInfoCard('Место работы', patientData['workplace'] ?? 'Не указано'),
          const SizedBox(height: 12),
          _buildInfoCard('Дата рождения', patientData['birth_date'] ?? 'Не указано'),
          const SizedBox(height: 12),
          _buildInfoCard('Возраст', patientData['age'] ?? 'Не указано'),
          
          // Лечащий врач
          if (patientData['attending_doctor'] != null) ...[
            const SizedBox(height: 16),
            _buildDoctorSection(patientData['attending_doctor'] as Map<String, dynamic>),
          ],
          
          // Полис
          if (patientData['policy'] != null) ...[
            const SizedBox(height: 16),
            _buildPolicySection(patientData['policy'] as Map<String, dynamic>),
          ],
          
          // Сертификат
          if (patientData['certificate'] != null) ...[
            const SizedBox(height: 16),
            _buildCertificateSection(patientData['certificate'] as Map<String, dynamic>),
          ],
          
          // Законный представитель
          if (patientData['legal_representative'] != null) ...[
            const SizedBox(height: 16),
            _buildLegalRepresentativeSection(patientData['legal_representative'] as Map<String, dynamic>),
          ],
          
          // Родственник
          if (patientData['relative'] != null) ...[
            const SizedBox(height: 16),
            _buildRelativeSection(patientData['relative'] as Map<String, dynamic>),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
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
