import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:demo_app/presentation/pages/patient_detail_screen.dart';
import 'package:demo_app/presentation/pages/patient_history_screen.dart';
import 'package:demo_app/presentation/pages/add_patient_screen.dart';
import '../widgets/responsive_card_list.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _patients = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get _filteredPatients {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return _patients;
    
    return _patients.where((patient) {
      return patient['full_name'].toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _fetchPatients() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    final url = Uri.parse('http://192.168.30.106:8080/api/v1/patients/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      
      if (responseData['status'] == 'success') {
        dynamic data = responseData['data'];
        List<dynamic> patientsData = [];

        // Обработка разных форматов ответа
        if (data is List) {
          patientsData = data;
        } else if (data is Map<String, dynamic>) {
          patientsData = [data];
        } else {
          throw Exception('Unexpected data type: ${data.runtimeType}');
        }

        setState(() {
          _patients = patientsData.map((patient) {
            return {
              'id': patient['ID'] ?? 0,
              'full_name': patient['full_name'] ?? 'Без имени',
              'is_male': patient['is_male'] ?? false, // Обрабатываем null
              'birth_date': patient['birth_date'] ?? '',
            };
          }).toList();
        });
      } else {
        throw Exception('Invalid response status: ${responseData['status']}');
      }
    } else {
      throw Exception('HTTP error ${response.statusCode}');
    }
  } catch (e) {
    setState(() {
      _errorMessage = 'Ошибка загрузки: ${e.toString()}';
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  Future<void> _refreshPatients() async {
    await _fetchPatients();
  }
  

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addNewPatient(Map<String, dynamic> patientData) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse('http://192.168.30.106:8080/api/v1/patients/');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'full_name': patientData['fullName'], // snake_case
          'birth_date': patientData['birthDate'],
          'is_male': patientData['gender'] == 'Мужской',
        }),
      );

      if (response.statusCode == 201) {
        await _fetchPatients(); // Обновляем список после добавления
      } else {
        throw Exception('Ошибка при добавлении пациента');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка добавления: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openPatientDetails(Map<String, dynamic> patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDetailScreen(
          patient: {
            ...patient,
            'contact_info': {
              'phone': 'Не указан',
              'email': 'Не указан',
              'address': 'Не указан',
            },
            'personal_info': {
              'snils': 'Не указан',
              'oms': 'Не указан',
              'passport': 'Не указан',
            },
          },
        ),
      ),
    );
  }

  void _openPatientHistory(Map<String, dynamic> patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientHistoryScreen(
          patientId: patient['id'],
          patientName: patient['full_name'], // Исправлено на snake_case
        ),
      ),
    );
  }

  void _openAddPatientScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPatientScreen()),
    ).then((result) {
      if (result != null) {
        _addNewPatient(result);
      }
    });
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'Пациенты',
        style: TextStyle(color: Color(0xFF8B8B8B)),
        ), // упрощенный заголовок
      backgroundColor: const Color(0xFFFFFFFF),
      toolbarHeight: 60, // уменьшенная высота
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Color(0xFF8B8B8B)), // Серый цвет
          onPressed: _refreshPatients,
          tooltip: 'Обновить список',
        ),
        IconButton(
          icon: const Icon(Icons.add, color: Color(0xFF8B8B8B)), // Серый цвет
          onPressed: _openAddPatientScreen,
          tooltip: 'Добавить пациента',
        ),
      ],
    ),
      body: _isLoading
    ? const Center(child: CircularProgressIndicator())
    : _errorMessage != null
        ? Center(child: Text('Ошибка: $_errorMessage'))
        : Column(
            children: [
              // Поле поиска
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Поиск пациентов...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
              ),
              Expanded(
                child: ResponsiveCardList(
                  type: CardListType.patients,
                  items: _filteredPatients,
                  onDetails: (item) => _openPatientDetails(item as Map<String, dynamic>),
                  onHistory: (item) => _openPatientHistory(item as Map<String, dynamic>),
                  onRefresh: _refreshPatients,
                ),
              ),
            ],
          ),
    );
  }
}
