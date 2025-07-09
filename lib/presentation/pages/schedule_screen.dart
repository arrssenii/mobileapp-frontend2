import 'package:flutter/material.dart';
import 'package:demo_app/presentation/pages/patient_detail_screen.dart';
import 'package:demo_app/presentation/pages/consultation_screen.dart';
import '../widgets/date_picker_icon_button.dart';
import '../../data/models/appointment_model.dart';
import '../widgets/action_tile.dart';
import '../widgets/date_carousel.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  List<Appointment> _appointments = [];
  // Удалены: _dates, _scrollController

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

  void _showAppointmentOptions(BuildContext context, Appointment appointment) {
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

  Widget _buildTimeSlot(Appointment appointment) {
    Color? cardColor;
    IconData? statusIcon;
    Color? iconColor;
    String statusText = '';

    switch (appointment.status) {
      case AppointmentStatus.noShow:
        cardColor = Colors.red.shade100;
        statusIcon = Icons.close;
        iconColor = Colors.red;
        statusText = 'Не явился';
        break;
      case AppointmentStatus.completed:
        cardColor = Colors.green.shade100;
        statusIcon = Icons.check;
        iconColor = Colors.green;
        statusText = 'Приём завершён';
        break;
      case AppointmentStatus.scheduled:
        default:
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: cardColor,
      child: InkWell(
        onTap: () => _showAppointmentOptions(context, appointment),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              Row(
                children: [
                  Container(
                    width: 80,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${appointment.time.hour}:00',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${appointment.time.hour + 1}:00',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const VerticalDivider(width: 20, thickness: 1),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.patientName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 16
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Кабинет ${appointment.cabinet}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Плановый осмотр',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (appointment.status != AppointmentStatus.scheduled)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: [
                      Icon(statusIcon, color: iconColor, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: iconColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
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
        
        // Используем новый виджет DateCarousel
        DateCarousel(
          initialDate: _selectedDate,
          onDateSelected: (date) {
            setState(() {
              _selectedDate = date;
            });
            _loadAppointments();
          },
          daysRange: 30, // Увеличили диапазон до 30 дней
        ),
        
        const SizedBox(height: 20),
        Text(
          'Расписание на ${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: _appointments.length,
            itemBuilder: (context, index) {
              return _buildTimeSlot(_appointments[index]);
            },
          ),
        ),
      ],
    );
  }
}