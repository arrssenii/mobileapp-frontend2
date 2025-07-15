import 'package:flutter/material.dart';
import 'package:demo_app/presentation/pages/patient_detail_screen.dart';
import 'package:demo_app/presentation/pages/consultation_screen.dart';
import '../widgets/date_picker_icon_button.dart';
import '../../data/models/appointment_model.dart';
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
  
  Future<void> _refreshAppointments() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _loadAppointments();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  void _loadAppointments() {
    setState(() {
      _appointments = List.generate(8, (index) {
        final hour = 8 + index;
        return Appointment(
          id: index,
          patientName: _getRandomPatientName(index),
          cabinet: '${201 + index % 3}',
          time: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, hour),
        );
      });
    });
  }

  void _handleDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _loadAppointments();
  }

  String _getRandomPatientName(int index) {
    final names = [
      'Иванов И.И.', 'Петрова А.С.', 'Сидоров Д.К.', 
      'Козлова М.П.', 'Никитин В.А.', 'Фёдорова О.И.',
      'Григорьев П.Д.', 'Семёнова Е.В.'
    ];
    return names[index % names.length];
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
      'room': 'Палата ${101 + appointment.id % 5}',
      'diagnosis': 'Диагноз не установлен',
      'gender': appointment.id % 2 == 0 ? 'Мужской' : 'Женский',
      'birthDate': '01.01.${1980 + appointment.id % 20}',
      'snils': '123-456-789 0${appointment.id}',
      'oms': '123456789012345${appointment.id}',
      'passport': '45 06 12345${appointment.id}',
      'address': 'г. Москва, ул. Примерная, д. ${10 + appointment.id}, кв. ${20 + appointment.id}',
      'phone': '+7 (999) 123-45-${appointment.id}',
      'email': 'patient${appointment.id}@example.com',
      'contraindications': 'Нет',
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
        title: Text(
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
        child: ResponsiveCardList(
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