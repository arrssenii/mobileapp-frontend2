import 'package:flutter/material.dart';
import 'patient_card.dart';

class PatientList extends StatefulWidget {
  final List<Map<String, dynamic>> patients;
  final TextEditingController searchController;
  final void Function(Map<String, dynamic> patient) onPatientDetails;
  final void Function(Map<String, dynamic> patient) onPatientHistory;
  final void Function() onAddPatient;
  final void Function(Map<String, dynamic> patient) onPatientAdded;

  const PatientList({
    super.key,
    required this.patients,
    required this.searchController,
    required this.onPatientDetails,
    required this.onPatientHistory,
    required this.onAddPatient,
    required this.onPatientAdded,
  });

  @override
  State<PatientList> createState() => _PatientListState();
}

class _PatientListState extends State<PatientList> {
  List<Map<String, dynamic>> _filteredPatients = [];

  @override
  void initState() {
    super.initState();
    widget.searchController.addListener(_filterPatients);
    _filteredPatients = widget.patients;
  }

  @override
  void didUpdateWidget(PatientList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.patients != widget.patients) {
      _filterPatients();
    }
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_filterPatients);
    super.dispose();
  }

  void _filterPatients() {
    final query = widget.searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() => _filteredPatients = widget.patients);
    } else {
      setState(() {
        _filteredPatients = widget.patients.where((patient) {
          return patient['fullName'].toLowerCase().contains(query);
        }).toList();
      });
    }
  }

  void _addNewPatient() {
    widget.onAddPatient();
    // Для демонстрации - в реальном приложении данные будут приходить из формы
    final newPatient = {
      'id': widget.patients.length + 1,
      'fullName': 'Новый пациент',
      'room': 'Палата не назначена',
      'diagnosis': 'Диагноз не установлен',
      'status': 'stable',
      'isCritical': false,
    };
    widget.onPatientAdded(newPatient);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Поле поиска
              Expanded(
                child: TextField(
                  controller: widget.searchController,
                  decoration: InputDecoration(
                    hintText: 'Поиск по ФИО пациента',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              
              // Кнопка фильтра
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.filter_list, size: 25, color: Colors.white),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Фильтрация будет реализована позже')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              
              // Кнопка добавления пациента
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, size: 25, color: Colors.white),
                  onPressed: _addNewPatient,
                  tooltip: 'Добавить пациента',
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: _filteredPatients.isEmpty
              ? const Center(
                  child: Text(
                    'Пациенты не найдены',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredPatients.length,
                  itemBuilder: (context, index) {
                    final patient = _filteredPatients[index];
                    return PatientCard(
                      patient: patient,
                      onDetails: () => widget.onPatientDetails(patient),
                      onHistory: () => widget.onPatientHistory(patient),
                      showStatusIndicator: true,
                      isSelected: false,
                    );
                  },
                ),
        ),
      ],
    );
  }
}