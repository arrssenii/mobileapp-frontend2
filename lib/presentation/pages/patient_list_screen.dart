import 'package:kvant_medpuls/presentation/pages/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kvant_medpuls/services/api_client.dart'; // Добавлен импорт
import 'package:kvant_medpuls/services/auth_service.dart'; // Добавляем импорт AuthService
import 'package:kvant_medpuls/presentation/pages/patient_detail_screen.dart';
import 'package:kvant_medpuls/presentation/pages/patient_history_screen.dart';
import 'package:kvant_medpuls/presentation/pages/add_patient_screen.dart';
import '../widgets/responsive_card_list.dart';
import 'package:kvant_medpuls/core/theme/theme_config.dart';

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
  late ApiClient _apiClient; // Изменяем на late
  bool _isInitialized = false;
  int _currentPage = 1;
  int _itemsPerPage =
      20; // Можно сделать настраиваемым или использовать дефолтное значение из API
  bool _hasMore = true; // Есть ли еще страницы?
  bool _isFetchingMore = false; // Загружается ли следующая страница?

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      _apiClient = Provider.of<ApiClient>(context, listen: false);
      _isInitialized = true;
      _fetchPatients();
    }
  }

  List<Map<String, dynamic>> get _filteredPatients {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return _patients;

    return _patients.where((patient) {
      final fullName = _buildFullName(patient).toLowerCase();
      return fullName.contains(query);
    }).toList();
  }

  Future<void> _fetchPatients({bool clearList = false}) async {
    if (_isFetchingMore || _isLoading)
      return; // Защита от дублирования запросов

    setState(() {
      if (clearList) {
        _patients = [];
        _currentPage = 1;
        _hasMore = true;
      }
      if (!clearList) {
        _isLoading = true;
      } else {
        _isLoading = true;
        _errorMessage = null;
      }
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final doctorId = await authService.getDoctorId();

      if (doctorId == null) {
        throw Exception('ID доктора не найден');
      }

      // Вызываем метод API с параметрами page и limit
      final patientsData = await _apiClient.getAllPatients(
        doctorId,
        page: _currentPage,
        limit: _itemsPerPage,
      );

      // Обработка данных
      final newPatients = patientsData.map((patient) {
        final patientId = patient['clientCode']?.toString() ?? '';
        final fullName = patient['clientName'] ?? '';
        final gender = patient['gender'] ?? '';
        final birthDate = patient['birthDate'] ?? '';

        final nameParts = fullName.split(' ');
        String lastName = '';
        String firstName = '';
        String middleName = '';

        if (nameParts.length >= 1) lastName = nameParts[0];
        if (nameParts.length >= 2) firstName = nameParts[1];
        if (nameParts.length >= 3) middleName = nameParts[2];

        return {
          'id': patientId,
          'patientId': patientId,
          'firstName': firstName,
          'lastName': lastName,
          'middleName': middleName,
          'is_male': gender == "Мужской",
          'birth_date': birthDate,
        };
      }).toList();

      setState(() {
        if (clearList) {
          _patients = newPatients;
        } else {
          _patients.addAll(newPatients);
        }

        // Если загрузили меньше, чем лимит — значит, больше нет страниц
        if (newPatients.length < _itemsPerPage) {
          _hasMore = false;
        } else {
          _hasMore = true;
        }
      });
    } on ApiError catch (e) {
      setState(() {
        _errorMessage = 'Ошибка загрузки: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
        _isFetchingMore = false;
      });
    }
  }

  Future<void> _loadMorePatients() async {
    if (!_hasMore || _isFetchingMore || _isLoading) return;

    setState(() {
      _isFetchingMore = true;
    });

    _currentPage++;

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final doctorId = await authService.getDoctorId();

      if (doctorId == null) {
        throw Exception('ID доктора не найден');
      }

      final patientsData = await _apiClient.getAllPatients(
        doctorId,
        page: _currentPage,
        limit: _itemsPerPage,
      );

      final newPatients = patientsData.map((patient) {
        final patientId = patient['clientCode']?.toString() ?? '';
        final fullName = patient['clientName'] ?? '';
        final gender = patient['gender'] ?? '';
        final birthDate = patient['birthDate'] ?? '';

        final nameParts = fullName.split(' ');
        String lastName = '';
        String firstName = '';
        String middleName = '';

        if (nameParts.length >= 1) lastName = nameParts[0];
        if (nameParts.length >= 2) firstName = nameParts[1];
        if (nameParts.length >= 3) middleName = nameParts[2];

        return {
          'id': patientId,
          'patientId': patientId,
          'firstName': firstName,
          'lastName': lastName,
          'middleName': middleName,
          'is_male': gender == "Мужской",
          'birth_date': birthDate,
        };
      }).toList();

      setState(() {
        _patients.addAll(newPatients);
        if (newPatients.length < _itemsPerPage) {
          _hasMore = false;
        }
      });
    } on ApiError catch (e) {
      setState(() {
        _errorMessage = 'Ошибка загрузки: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isFetchingMore = false;
      });
    }
  }

  Future<void> _refreshPatients() async {
    _currentPage = 1;
    _hasMore = true;
    await _fetchPatients(clearList: true);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openPatientDetails(Map<String, dynamic> patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDetailScreen(
          patientId: patient['id'].toString(), // Преобразуем ID в строку
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
          patientName: _buildFullName(patient), // Исправлено на snake_case
        ),
      ),
    );
  }

  String _buildFullName(Map<String, dynamic> patient) {
    final lastName = patient['lastName'] ?? patient['last_name'] ?? '';
    final firstName = patient['firstName'] ?? patient['first_name'] ?? '';
    final middleName = patient['middleName'] ?? patient['middle_name'] ?? '';
    return '$lastName $firstName $middleName'.trim();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null &&
        _errorMessage!.contains('Данные доктора не загружены')) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Данные доктора не загружены'),
            ElevatedButton(
              onPressed: _fetchPatients,
              child: const Text('Повторить попытку'),
            ),
          ],
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Пациенты',
          style: TextStyle(color: AppTheme.textSecondary),
        ), // упрощенный заголовок
        backgroundColor: Colors.white,
        toolbarHeight: 60, // уменьшенная высота
        leading: IconButton(
          // ← Кнопка выхода слева
          icon: const Icon(Icons.logout, color: AppTheme.textSecondary),
          tooltip: 'Выйти',
          onPressed: () {
            // Чистим данные и выходим
            Provider.of<ApiClient>(context, listen: false).logout();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: AppTheme.textSecondary,
            ), // Серый цвет
            onPressed: _refreshPatients,
            tooltip: 'Обновить список',
          ),
          // IconButton(
          //   icon: const Icon(Icons.add, color: AppTheme.textSecondary), // Серый цвет
          //   onPressed: _openAddPatientScreen,
          //   tooltip: 'Добавить пациента',
          // ),
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
                    items:
                        _filteredPatients, // Теперь тип List<Map<String, dynamic>>
                    onDetails: _openPatientDetails, // Прямая передача
                    onHistory: _openPatientHistory, // Прямая передача
                    onRefresh: _refreshPatients,
                    onScrollEnd: _hasMore && !_isFetchingMore
                        ? _loadMorePatients
                        : null,
                    isLoadingMore: _isFetchingMore,
                    hasMore: _hasMore,
                  ),
                ),
              ],
            ),
    );
  }
}
