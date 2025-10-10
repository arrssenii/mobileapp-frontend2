import 'package:flutter/material.dart';
import '../widgets/custom_card.dart';
import '../../core/theme/theme_config.dart';

class ServicesScreen extends StatefulWidget {
  final int patientId;
  final int receptionId;
  final Function(List<Map<String, dynamic>>)? onServicesSelected;

  const ServicesScreen({
    super.key,
    required this.patientId,
    required this.receptionId,
    this.onServicesSelected,
  });

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final List<Map<String, dynamic>> _selectedServices = [];
  double _totalAmount = 0;

  // Структура данных услуг с главными папками и подпапками
  final List<Map<String, dynamic>> _medicalServices = [
    {
      'category': 'Терапия',
      'isOpen': false,
      'subfolders': [
        {
          'name': 'Диагностика',
          'isOpen': false,
          'services': [
            {
              'id': 1,
              'name': 'Комплексная диагностика',
              'price': 3500,
              'description': 'Полное обследование организма'
            },
            {
              'id': 2,
              'name': 'ЭКГ с расшифровкой',
              'price': 1200,
              'description': 'Электрокардиограмма'
            },
          ]
        },
        {
          'name': 'Лаборатория',
          'isOpen': false,
          'services': [
            {
              'id': 3,
              'name': 'Расширенный анализ крови',
              'price': 2200,
              'description': 'Биохимия + гормоны'
            },
            {
              'id': 4,
              'name': 'Анализ мочи',
              'price': 600,
              'description': 'Общий анализ мочи'
            },
          ]
        },
        {
          'name': 'Консультации',
          'isOpen': false,
          'services': [
            {
              'id': 5,
              'name': 'Первичный прием терапевта',
              'price': 1800,
              'description': 'Первичная консультация'
            },
            {
              'id': 6,
              'name': 'Повторный прием терапевта',
              'price': 1400,
              'description': 'Контрольное посещение'
            },
          ]
        },
      ]
    },
    {
      'category': 'Хирургия',
      'isOpen': false,
      'subfolders': [
        {
          'name': 'Общая хирургия',
          'isOpen': false,
          'services': [
            {
              'id': 7,
              'name': 'Консультация хирурга',
              'price': 2500,
              'description': 'Первичная консультация'
            },
            {
              'id': 8,
              'name': 'Малая операция',
              'price': 9500,
              'description': 'Амбулаторная операция'
            },
          ]
        },
        {
          'name': 'Пластическая хирургия',
          'isOpen': false,
          'services': [
            {
              'id': 9,
              'name': 'Консультация пластического хирурга',
              'price': 3500,
              'description': 'Специализированная консультация'
            },
            {
              'id': 10,
              'name': 'Блефаропластика',
              'price': 45000,
              'description': 'Пластика век'
            },
          ]
        },
      ]
    },
    {
      'category': 'Диагностика',
      'isOpen': false,
      'subfolders': [
        {
          'name': 'УЗИ',
          'isOpen': false,
          'services': [
            {
              'id': 11,
              'name': 'УЗИ брюшной полости',
              'price': 2200,
              'description': 'Комплексное исследование'
            },
            {
              'id': 12,
              'name': 'УЗИ молочных желез',
              'price': 1800,
              'description': 'Маммография УЗИ'
            },
          ]
        },
        {
          'name': 'Рентген',
          'isOpen': false,
          'services': [
            {
              'id': 13,
              'name': 'Рентген грудной клетки',
              'price': 1500,
              'description': 'Одна проекция'
            },
            {
              'id': 14,
              'name': 'Рентген позвоночника',
              'price': 2800,
              'description': 'Три проекции'
            },
          ]
        },
      ]
    },
  ];

  void _toggleMainFolder(int categoryIndex) {
    setState(() {
      _medicalServices[categoryIndex]['isOpen'] = 
          !_medicalServices[categoryIndex]['isOpen'];
    });
  }

  void _toggleSubFolder(int categoryIndex, int subfolderIndex) {
    setState(() {
      final subfolders = _medicalServices[categoryIndex]['subfolders'] as List;
      subfolders[subfolderIndex]['isOpen'] = 
          !subfolders[subfolderIndex]['isOpen'];
    });
  }

  void _toggleService(Map<String, dynamic> service, String category, String subfolder) {
    setState(() {
      final serviceWithCategory = {
        ...service,
        'category': category,
        'subfolder': subfolder,
      };

      final isSelected = _selectedServices.any((s) => s['id'] == service['id']);
      
      if (isSelected) {
        _selectedServices.removeWhere((s) => s['id'] == service['id']);
        _totalAmount -= service['price'];
      } else {
        _selectedServices.add(serviceWithCategory);
        _totalAmount += service['price'];
      }
    });
  }

  bool _isServiceSelected(int serviceId) {
    return _selectedServices.any((service) => service['id'] == serviceId);
  }

  void _confirmSelection() {
    if (widget.onServicesSelected != null) {
      widget.onServicesSelected!(_selectedServices);
    }
    Navigator.pop(context, _selectedServices);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Номенклатура услуг'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Заголовок каталога
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Каталог услуг',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          
          // Дерево категорий и услуг
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _medicalServices.length,
              itemBuilder: (context, categoryIndex) {
                final category = _medicalServices[categoryIndex];
                return _buildMainFolder(category, categoryIndex);
              },
            ),
          ),
          
          // Нижняя панель с информацией и кнопкой
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Информация о выбранных услугах
                if (_selectedServices.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFf8fafc),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Выбрано услуг:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              '${_selectedServices.length}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Итоговая сумма:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              '${_totalAmount.toInt()} ₽',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                
                // Кнопка подтверждения
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedServices.isEmpty ? null : _confirmSelection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedServices.isEmpty
                          ? Colors.grey
                          : AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      _selectedServices.isEmpty ? 'Выберите услуги' : 'Подтвердить выбор',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildMainFolder(Map<String, dynamic> category, int categoryIndex) {
    final isOpen = category['isOpen'] as bool;
    final subfolders = category['subfolders'] as List;

    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          // Заголовок главной папки
          ListTile(
            title: Text(
              category['category'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Icon(
              isOpen ? Icons.expand_less : Icons.expand_more,
              color: AppTheme.primaryColor,
            ),
            onTap: () => _toggleMainFolder(categoryIndex),
          ),
          
          // Содержимое главной папки
          if (isOpen)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: List.generate(subfolders.length, (subfolderIndex) {
                  final subfolder = subfolders[subfolderIndex];
                  return _buildSubFolder(subfolder, categoryIndex, subfolderIndex);
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubFolder(Map<String, dynamic> subfolder, int categoryIndex, int subfolderIndex) {
    final isOpen = subfolder['isOpen'] as bool;
    final services = subfolder['services'] as List;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: AppTheme.primaryColor,
            width: 3,
          ),
        ),
      ),
      child: Column(
        children: [
          // Заголовок подпапки
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFf8f9fa),
              borderRadius: BorderRadius.circular(6),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                subfolder['name'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Icon(
                isOpen ? Icons.expand_less : Icons.expand_more,
                color: AppTheme.primaryColor,
              ),
              onTap: () => _toggleSubFolder(categoryIndex, subfolderIndex),
            ),
          ),
          
          // Содержимое подпапки
          if (isOpen)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                children: List.generate(services.length, (serviceIndex) {
                  final service = services[serviceIndex];
                  return _buildServiceItem(service, categoryIndex, subfolderIndex);
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(Map<String, dynamic> service, int categoryIndex, int subfolderIndex) {
    final isSelected = _isServiceSelected(service['id']);
    final category = _medicalServices[categoryIndex]['category'];
    final subfolder = _medicalServices[categoryIndex]['subfolders'][subfolderIndex]['name'];

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Checkbox(
        value: isSelected,
        onChanged: (value) => _toggleService(service, category, subfolder),
        activeColor: AppTheme.primaryColor,
      ),
      title: Text(
        service['name'],
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            service['description'],
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${service['price']} ₽',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFe74c3c),
            ),
          ),
        ],
      ),
      onTap: () => _toggleService(service, category, subfolder),
    );
  }
}