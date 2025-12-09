import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'schedule_screen.dart';
import 'patient_list_screen.dart';
import 'calls_screen.dart';
import '../../services/auth_service.dart';
import '../../providers/websocket_provider.dart'; // 👈 Импортируем WebSocketProvider

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [PatientListScreen(), CallsScreen()];

  @override
  void initState() {
    super.initState();
    // Подключаемся к вебсокету после инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectWebSocket();
    });
  }

  Future<void> _connectWebSocket() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      // ✅ Используем WebSocketProvider вместо WebSocketService
      final webSocketProvider = Provider.of<WebSocketProvider>(
        context,
        listen: false,
      );

      final doctorId = await authService.getDoctorId();
      if (doctorId != null) {
        await webSocketProvider.connect(
          doctorId.toString(),
        ); // Подключаем через провайдер
        debugPrint(
          '✅ WebSocket подключен через WebSocketProvider для доктора: $doctorId',
        );
      } else {
        debugPrint('⚠️ ID доктора не найден, WebSocket не подключен');
      }
    } catch (e) {
      debugPrint('❌ Ошибка подключения WebSocket: $e');
    }
  }

  @override
  void dispose() {
    // ❌ НЕ НУЖНО отключать WebSocketService напрямую
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
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
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
            elevation: 0,
          ),
        ),
      ),
    );
  }
}
