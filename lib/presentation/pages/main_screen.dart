import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Убедитесь, что этот импорт больше не нужен, если вы его удаляете из проекта
// import 'package:your_package/websocket_provider.dart'; // или websocket_service.dart
import 'schedule_screen.dart';
import 'patient_list_screen.dart';
import 'calls_screen.dart';
// Убедитесь, что этот импорт больше не нужен, если вы его удаляете из проекта
// import '../../services/websocket_service.dart'; // или другой файл сервиса/провайдера вебсокета

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1;

  final List<Widget> _pages = [
    PatientListScreen(),
    CallsScreen(),
    // Добавьте другие экраны, если они есть, например, ScheduleScreen
    // ScheduleScreen(),
  ];

  // Убираем подключение WebSocket из initState
  @override
  void initState() {
    super.initState();
    // Удаляем весь код, связанный с WebSocket
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _connectWebSocket();
    // });
  }

  // Убираем метод подключения WebSocket
  // Future<void> _connectWebSocket() async {
  //   try {
  //     final authService = Provider.of<AuthService>(context, listen: false);
  //     final webSocketProvider = Provider.of<WebSocketProvider>(
  //       context,
  //       listen: false,
  //     );
  //     final doctorId = await authService.getDoctorId();
  //     if (doctorId != null) {
  //       await webSocketProvider.connect(doctorId.toString());
  //       debugPrint('✅ WebSocket подключен через WebSocketProvider для доктора: $doctorId');
  //     } else {
  //       debugPrint('⚠️ ID доктора не найден, WebSocket не подключен');
  //     }
  //   } catch (e) {
  //     debugPrint('❌ Ошибка подключения WebSocket: $e');
  //   }
  // }

  @override
  void dispose() {
    // Убираем отключение WebSocket из dispose
    // final webSocketService = Provider.of<WebSocketService>(context, listen: false);
    // webSocketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4682B4).withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -2), // Тень сверху
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(15), // Закругление верхних углов
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                activeIcon: Icon(Icons.people, size: 28),
                label: 'Пациенты',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_hospital_outlined),
                activeIcon: Icon(Icons.local_hospital, size: 28),
                label: 'Вызовы',
              ),
              // Добавьте другие BottomNavigationBarItem, если добавляете больше экранов
            ],
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            backgroundColor: const Color(0xFF4682B4),
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            elevation: 0, // Убираем тень от BottomNavigationBar, если она есть
          ),
        ),
      ),
    );
  }
}
