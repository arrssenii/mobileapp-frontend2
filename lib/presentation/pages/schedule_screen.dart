import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:demo_app/data/models/appointment_model.dart'; // Добавлен импорт модели
import 'package:demo_app/presentation/pages/patient_detail_screen.dart';
import 'package:demo_app/presentation/pages/consultation_screen.dart';
import '../widgets/date_picker_icon_button.dart';
import '../widgets/action_tile.dart';
import '../widgets/date_carousel.dart';
import '../widgets/responsive_card_list.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  List<Appointment> _appointments = [];
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final formattedDate = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
      final url = Uri.parse('http://192.168.30.106:8080/api/v1/recepHospital/1?date=$formattedDate&page=1');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> hits = data['hits'];

        setState(() {
          _appointments = hits.map((hit) {
            // Парсим дату из формата "dd.MM.yyyy HH:mm"
            final dateParts = (hit['date'] as String).split(' ');
            final dateStr = dateParts[0];
            final timeStr = dateParts[1];
            
            final dateComponents = dateStr.split('.').map(int.parse).toList();
            final timeComponents = timeStr.split(':').map(int.parse).toList();
            
            return Appointment(
              id: hit['id'],
              patientName: hit['patient_name'],
              diagnosis: hit['diagnosis'] ?? 'Диагноз не указан',
              address: hit['address'] ?? 'Адрес не указан',
              time: DateTime(
                dateComponents[2], 
                dateComponents[1], 
                dateComponents[0],
                timeComponents[0],
                timeComponents[1],
              ),
              status: _parseStatus(hit['status']),
            );
          }).toList();
        });
      } else {
        throw Exception('Failed to load appointments: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  AppointmentStatus _parseStatus(String status) {
    switch (status) {
      case 'Завершен':
        return AppointmentStatus.completed;
      case 'Не явился':
        return AppointmentStatus.noShow;
      case 'Запланирован':
      default:
        return AppointmentStatus.scheduled;
    }
  }

  Future<void> _refreshAppointments() async {
    await _loadAppointments();
  }

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  void _handleDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _loadAppointments();
  }

  void _showAppointmentOptions(dynamic appointmentData) {
    final appointment = appointmentData as Appointment;
    showDialog(
      context: context,
      builder: (context) {
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
                    icon: Icons.person,
                    title: 'Информация о пациенте',
                    onTap: () {
                      Navigator.pop(context);
                      _openPatientDetails(context, appointment);
                    },
                  ),
                  ActionTile(
                    icon: Icons.medical_services,
                    title: 'Начать приём',
                    onTap: () {
                      Navigator.pop(context);
                      _openConsultationScreen(context, appointment);
                    },
                  ),
                  ActionTile(
                    icon: Icons.close,
                    title: 'Не явился',
                    onTap: () {
                      setState(() {
                        appointment.status = AppointmentStatus.noShow;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    child: const Text('Отмена', 
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
      },
    );
  }

  void _openPatientDetails(BuildContext context, Appointment appointment) {
    final patient = {
      'id': appointment.id,
      'fullName': appointment.patientName,
      'diagnosis': appointment.diagnosis,
      'address': appointment.address,
      // Остальные поля можно заполнить по мере необходимости
    };
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDetailScreen(patient: patient),
      ),
    );
  }

  void _openConsultationScreen(BuildContext context, Appointment appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConsultationScreen(
          patientName: appointment.patientName,
          appointmentType: 'appointment',
          recordId: appointment.id,
        ),
      ),
    ).then((result) {
      if (result != null) {
        setState(() {
          appointment.status = AppointmentStatus.completed;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Заключение врача сохранено'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: const Text(
            'Расписание приёмов',
            style: TextStyle(color: Color(0xFF8B8B8B)),
          ),
          backgroundColor: const Color(0xFFFFFFFF),
          actions: [
            DatePickerIconButton(
              initialDate: _selectedDate,
              onDateSelected: _handleDateSelected,
              tooltip: 'Выбрать дату расписания',
            ),
          ],
        ),
        
        DateCarousel(
          initialDate: _selectedDate,
          onDateSelected: (date) {
            setState(() => _selectedDate = date);
            _loadAppointments();
          },
          daysRange: 30,
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            'Расписание на ${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        Expanded(
          child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
              ? Center(child: Text('Ошибка: $_errorMessage'))
              : ResponsiveCardList(
                  type: CardListType.schedule,
                  items: _appointments,
                  onItemTap: (context, item) => _showAppointmentOptions(item),
                  onRefresh: _refreshAppointments,
                ),
        ),
      ],
    );
  }
}