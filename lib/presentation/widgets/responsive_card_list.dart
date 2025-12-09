import 'package:flutter/material.dart';
import 'appointment_card.dart';
import 'call_card.dart';
import 'patient_card.dart';
import '../../data/models/appointment_model.dart';
import '../../core/theme/theme_config.dart';

enum CardListType { schedule, calls, patients }

class ResponsiveCardList extends StatefulWidget {
  final CardListType type;
  final List<Map<String, dynamic>> items;
  final Function(BuildContext, dynamic)? onItemTap;
  final Function(Map<String, dynamic>)? onDetails;
  final Function(Map<String, dynamic>)? onHistory;
  final TextEditingController? searchController;
  final Function()? onAdd;
  final Function(dynamic)? onItemAdded;
  final bool showSearch;
  final Future<void> Function()? onRefresh;
  // --- НОВЫЕ ПАРАМЕТРЫ ---
  final Future<void> Function()?
  onScrollEnd; // Будет вызвано при достижении конца списка
  // ----------------------
  final bool isLoadingMore; // Индикатор загрузки "ещё" данных
  final bool hasMore; // Есть ли ещё данные для загрузки

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
    this.onRefresh,
    this.onScrollEnd, // Добавляем коллбэк
    this.isLoadingMore = false, // Добавляем индикатор
    this.hasMore = true, // Добавляем флаг
  });

  @override
  State<ResponsiveCardList> createState() => _ResponsiveCardListState();
}

class _ResponsiveCardListState extends State<ResponsiveCardList> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        widget.hasMore &&
        !widget.isLoadingMore) {
      widget.onScrollEnd?.call(); // Вызываем внешнюю функцию подгрузки
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget listContent = widget.items.isEmpty
        ? _buildEmptyState()
        : ListView.builder(
            controller: _scrollController, // Используем внутренний контроллер
            itemCount:
                widget.items.length +
                (widget.hasMore && widget.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= widget.items.length) {
                // Индикатор загрузки "ещё"
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        const SizedBox(height: 8),
                        Text('Загрузка...'),
                      ],
                    ),
                  ),
                );
              }

              final item = widget.items[index];
              switch (widget.type) {
                case CardListType.schedule:
                  return AppointmentCard(
                    appointment: item as Appointment,
                    onTap: () => widget.onItemTap?.call(context, item),
                  );
                case CardListType.calls:
                  return CallCard(
                    call: item as Map<String, dynamic>,
                    onTap: () => widget.onItemTap?.call(context, item),
                  );
                case CardListType.patients:
                  return PatientCard(
                    patient: item as Map<String, dynamic>,
                    onDetails: () => widget.onDetails?.call(item),
                    onHistory: () => widget.onHistory?.call(item),
                  );
              }
            },
          );

    if (widget.onRefresh != null) {
      listContent = RefreshIndicator(
        onRefresh: widget.onRefresh!,
        child: listContent,
      );
    }

    return Column(
      children: [
        if (widget.showSearch) _buildSearchRow(context),
        Expanded(child: listContent),
      ],
    );
  }

  Widget _buildSearchRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.searchController,
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
          if (widget.type == CardListType.patients)
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.filter_list,
                  size: 25,
                  color: AppTheme.textLight,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Фильтрация будет реализована позже'),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(width: 10),
          if (widget.onAdd != null)
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.add,
                  size: 25,
                  color: AppTheme.textLight,
                ),
                onPressed: widget.onAdd,
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
          Icon(_getEmptyStateIcon(), size: 64, color: AppTheme.textSecondary),
          const SizedBox(height: 20),
          Text(
            _getEmptyStateText(),
            style: TextStyle(fontSize: 18, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  String _getSearchHint() {
    switch (widget.type) {
      case CardListType.schedule:
        return 'Поиск по пациенту';
      case CardListType.calls:
        return 'Поиск по адресу';
      case CardListType.patients:
        return 'Поиск по ФИО пациента';
    }
  }

  String _getAddButtonTooltip() {
    switch (widget.type) {
      case CardListType.schedule:
        return 'Добавить запись';
      case CardListType.calls:
        return 'Создать вызов';
      case CardListType.patients:
        return 'Добавить пациента';
    }
  }

  IconData _getEmptyStateIcon() {
    switch (widget.type) {
      case CardListType.schedule:
        return Icons.calendar_today;
      case CardListType.calls:
        return Icons.local_hospital;
      case CardListType.patients:
        return Icons.people;
    }
  }

  String _getEmptyStateText() {
    switch (widget.type) {
      case CardListType.schedule:
        return 'На выбранную дату приёмов нет';
      case CardListType.calls:
        return 'Активных вызовов нет';
      case CardListType.patients:
        return 'Пациенты не найдены';
    }
  }
}
