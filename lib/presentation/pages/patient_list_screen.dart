import 'package:flutter/material.dart';
import 'patient_detail_screen.dart';
import 'patient_history_screen.dart';
import 'add_patient_screen.dart';
import '../widgets/patient_list.dart'; // Импортируем новый виджет

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _patients = [];

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadPatients() {
    // Фиктивные данные пациентов
    _patients = [
    {
      'id': 1,
      'fullName': 'Иванов Иван Иванович',
      'room': 'Палата 101',
      'diagnosis': 'Гипертоническая болезнь II ст.',
      'gender': 'Мужской',
      'birthDate': '15.03.1965',
      'snils': '123-456-789 01',
      'oms': '1234567890123456',
      'passport': '45 06 123456',
      'address': 'г. Москва, ул. Ленина, д. 15, кв. 42',
      'phone': '+7 (999) 123-45-67',
      'email': 'ivanov@example.com',
      'contraindications': 'Аллергия на пенициллин',
      'status': 'stable',
      'isCritical': false,
      'lastVisit': '10.05.2023',
      'bloodType': 'A(II) Rh+',
    },
    {
      'id': 2,
      'fullName': 'Петрова Анна Сергеевна',
      'room': 'Палата 205',
      'diagnosis': 'Сахарный диабет 2 типа',
      'gender': 'Женский',
      'birthDate': '22.07.1978',
      'snils': '234-567-890 12',
      'oms': '2345678901234567',
      'passport': '40 07 234567',
      'address': 'г. Санкт-Петербург, ул. Пушкина, д. 10, кв. 15',
      'phone': '+7 (911) 234-56-78',
      'email': 'petrova@example.com',
      'contraindications': 'Нет',
      'status': 'stable',
      'isCritical': false,
      'lastVisit': '15.05.2023',
      'bloodType': 'B(III) Rh+',
    },
    {
      'id': 3,
      'fullName': 'Сидоров Михаил Петрович',
      'room': 'Палата 102',
      'diagnosis': 'ХОБЛ, среднетяжелое течение',
      'gender': 'Мужской',
      'birthDate': '05.11.1952',
      'snils': '345-678-901 23',
      'oms': '3456789012345678',
      'passport': '41 08 345678',
      'address': 'г. Новосибирск, ул. Гагарина, д. 5, кв. 33',
      'phone': '+7 (912) 345-67-89',
      'email': 'sidorov@example.com',
      'contraindications': 'Бронхиальная астма',
      'status': 'pending',
      'isCritical': true,
      'lastVisit': '20.05.2023',
      'bloodType': 'O(I) Rh+',
    },
    {
      'id': 4,
      'fullName': 'Кузнецова Елена Владимировна',
      'room': 'Палата 306',
      'diagnosis': 'Остеоартроз коленных суставов',
      'gender': 'Женский',
      'birthDate': '18.09.1960',
      'snils': '456-789-012 34',
      'oms': '4567890123456789',
      'passport': '42 09 456789',
      'address': 'г. Екатеринбург, ул. Мира, д. 20, кв. 7',
      'phone': '+7 (913) 456-78-90',
      'email': 'kuznetsova@example.com',
      'contraindications': 'Непереносимость НПВС',
      'status': 'stable',
      'isCritical': false,
      'lastVisit': '12.05.2023',
      'bloodType': 'AB(IV) Rh-',
    },
    {
      'id': 5,
      'fullName': 'Смирнов Алексей Дмитриевич',
      'room': 'Палата 103',
      'diagnosis': 'ИБС, стенокардия напряжения II ФК',
      'gender': 'Мужской',
      'birthDate': '30.01.1972',
      'snils': '567-890-123 45',
      'oms': '5678901234567890',
      'passport': '43 10 567890',
      'address': 'г. Казань, ул. Чехова, д. 12, кв. 24',
      'phone': '+7 (914) 567-89-01',
      'email': 'smirnov@example.com',
      'contraindications': 'Язвенная болезнь желудка',
      'status': 'critical',
      'isCritical': true,
      'lastVisit': '18.05.2023',
      'bloodType': 'A(II) Rh-',
    },
    {
      'id': 6,
      'fullName': 'Федорова Ольга Игоревна',
      'room': 'Палата 207',
      'diagnosis': 'Хронический пиелонефрит',
      'gender': 'Женский',
      'birthDate': '14.05.1985',
      'snils': '678-901-234 56',
      'oms': '6789012345678901',
      'passport': '44 11 678901',
      'address': 'г. Нижний Новгород, ул. Горького, д. 8, кв. 19',
      'phone': '+7 (915) 678-90-12',
      'email': 'fedorova@example.com',
      'contraindications': 'Хроническая почечная недостаточность',
      'status': 'stable',
      'isCritical': false,
      'lastVisit': '22.05.2023',
      'bloodType': 'B(III) Rh-',
    },
    {
      'id': 7,
      'fullName': 'Попов Денис Александрович',
      'room': 'Палата 104',
      'diagnosis': 'Язвенная болезнь 12-перстной кишки',
      'gender': 'Мужской',
      'birthDate': '27.12.1979',
      'snils': '789-012-345 67',
      'oms': '7890123456789012',
      'passport': '45 12 789012',
      'address': 'г. Самара, ул. Куйбышева, д. 25, кв. 11',
      'phone': '+7 (916) 789-01-23',
      'email': 'popov@example.com',
      'contraindications': 'Аллергия на метронидазол',
      'status': 'pending',
      'isCritical': false,
      'lastVisit': '25.05.2023',
      'bloodType': 'O(I) Rh-',
    },
    {
      'id': 8,
      'fullName': 'Волкова Татьяна Николаевна',
      'room': 'Палата 308',
      'diagnosis': 'Бронхиальная астма, атопическая',
      'gender': 'Женский',
      'birthDate': '03.08.1992',
      'snils': '890-123-456 78',
      'oms': '8901234567890123',
      'passport': '46 13 890123',
      'address': 'г. Ростов-на-Дону, ул. Садовая, д. 3, кв. 5',
      'phone': '+7 (917) 890-12-34',
      'email': 'volkova@example.com',
      'contraindications': 'Поливалентная лекарственная аллергия',
      'status': 'critical',
      'isCritical': true,
      'lastVisit': '28.05.2023',
      'bloodType': 'AB(IV) Rh+',
    }
  ];
}

  void _addNewPatient(Map<String, dynamic> patientData) {
    setState(() {
      _patients.add({
        'id': _patients.length + 1,
        'fullName': patientData['fullName'] ?? 'Новый пациент',
        'room': 'Палата не назначена',
        'diagnosis': 'Диагноз не установлен',
        'status': 'stable',
        'isCritical': false,
      });
    });
  }

  void _openPatientDetails(Map<String, dynamic> patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDetailScreen(patient: patient),
      ),
    );
  }

  void _openPatientHistory(Map<String, dynamic> patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientHistoryScreen(
          patientId: patient['id'],
          patientName: patient['fullName'],
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
    return PatientList(
      patients: _patients,
      searchController: _searchController,
      onPatientDetails: _openPatientDetails,
      onPatientHistory: _openPatientHistory,
      onAddPatient: _openAddPatientScreen,
      onPatientAdded: _addNewPatient,
    );
  }
}