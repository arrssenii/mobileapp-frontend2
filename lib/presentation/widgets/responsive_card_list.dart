import 'package:flutter/material.dart';
import 'appointment_card.dart';
import 'call_card.dart';
import 'patient_card.dart';
import '../../data/models/appointment_model.dart';

enum CardListType {
  schedule,
  calls,
  patients,
}

class ResponsiveCardList extends StatelessWidget {
  final CardListType type;
  final List<dynamic> items;
  final Function(BuildContext, dynamic)? onItemTap;
  final Function(dynamic)? onDetails;
  final Function(dynamic)? onHistory;
  final TextEditingController? searchController;
  final Function()? onAdd;
  final Function(dynamic)? onItemAdded;
  final bool showSearch;
  final Future<void> Function()? onRefresh; // Новый параметр для обновления

  const ResponsiveCardList({
    super.key,
    required this.type,
    required this.items,
    this.onItemTap,
    this.onDetails,
    this.onHistory,
    this.searchController,
    this.onAdd,
    this.onItemAdded,
    this.showSearch = false,
    this.onRefresh, // Опциональный параметр
  });

  @override
  Widget build(BuildContext context) {
    Widget listContent = items.isEmpty
        ? _buildEmptyState()
        : ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              switch (type) {
                case CardListType.schedule:
                  return AppointmentCard(
                    appointment: item as Appointment,
                    onTap: () => onItemTap?.call(context, item),
                  );
                case CardListType.calls:
                  return CallCard(
                    call: item as Map<String, dynamic>,
                    onTap: () => onItemTap?.call(context, item),
                  );
                case CardListType.patients:
                  return PatientCard(
                    patient: item as Map<String, dynamic>,
                    onDetails: () => onDetails?.call(item),
                    onHistory: () => onHistory?.call(item),
                  );
              }
            },
          );

    // Добавляем RefreshIndicator если передан onRefresh
    if (onRefresh != null) {
      listContent = RefreshIndicator(
        onRefresh: onRefresh!,
        child: listContent,
      );
    }

    return Column(
      children: [
        if (showSearch) _buildSearchRow(context),
        Expanded(child: listContent),
      ],
    );
  }

  Widget _buildSearchRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Поле поиска
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: _getSearchHint(),
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
          if (type == CardListType.patients)
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
          
          // Кнопка добавления
          if (onAdd != null)
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.add, size: 25, color: Colors.white),
                onPressed: onAdd,
                tooltip: _getAddButtonTooltip(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getEmptyStateIcon(),
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            _getEmptyStateText(),
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _getSearchHint() {
    switch (type) {
      case CardListType.schedule:
        return 'Поиск по пациенту';
      case CardListType.calls:
        return 'Поиск по адресу';
      case CardListType.patients:
        return 'Поиск по ФИО пациента';
    }
  }

  String _getAddButtonTooltip() {
    switch (type) {
      case CardListType.schedule:
        return 'Добавить запись';
      case CardListType.calls:
        return 'Создать вызов';
      case CardListType.patients:
        return 'Добавить пациента';
    }
  }

  IconData _getEmptyStateIcon() {
    switch (type) {
      case CardListType.schedule:
        return Icons.calendar_today;
      case CardListType.calls:
        return Icons.local_hospital;
      case CardListType.patients:
        return Icons.people;
    }
  }

  String _getEmptyStateText() {
    switch (type) {
      case CardListType.schedule:
        return 'На выбранную дату приёмов нет';
      case CardListType.calls:
        return 'Активных вызовов нет';
      case CardListType.patients:
        return 'Пациенты не найдены';
    }
  }
}