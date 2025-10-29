import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Утилиты для оптимизации производительности
class PerformanceUtils {
  /// Создает ключ для ленивой загрузки
  static String createLazyKey(String baseKey, int index) {
    return '${baseKey}_$index';
  }

  /// Проверяет, находится ли виджет в области видимости
  static bool isWidgetInViewport(BuildContext context, GlobalKey key) {
    final renderObject = key.currentContext?.findRenderObject();
    if (renderObject is RenderBox) {
      final widgetRect = renderObject.localToGlobal(Offset.zero) & renderObject.size;
      final viewport = MediaQuery.of(context).size;
      final viewportRect = Offset.zero & viewport;
      return widgetRect.overlaps(viewportRect);
    }
    return false;
  }

  /// Оптимизирует перерисовку виджета
  static Widget optimizeRebuild(Widget child, [Key? key]) {
    return KeyedSubtree(
      key: key,
      child: child,
    );
  }
}

/// Виджет для ленивой загрузки изображений
class LazyImage extends StatefulWidget {
  final String imageUrl;
  final String placeholderAsset;
  final double? width;
  final double? height;
  final BoxFit? fit;

  const LazyImage({
    super.key,
    required this.imageUrl,
    required this.placeholderAsset,
    this.width,
    this.height,
    this.fit,
  });

  @override
  State<LazyImage> createState() => _LazyImageState();
}

class _LazyImageState extends State<LazyImage> {
  late ImageProvider _imageProvider;
  bool _isLoading = true;
  bool _isInViewport = false;

  @override
  void initState() {
    super.initState();
    _imageProvider = NetworkImage(widget.imageUrl);
    _checkViewport();
  }

  void _checkViewport() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isVisible = PerformanceUtils.isWidgetInViewport(context, GlobalKey());
      if (isVisible && !_isInViewport) {
        setState(() {
          _isInViewport = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: _isInViewport
          ? Image(
              image: _imageProvider,
              fit: widget.fit,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  _isLoading = false;
                  return child;
                }
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  widget.placeholderAsset,
                  fit: widget.fit,
                );
              },
            )
          : Image.asset(
              widget.placeholderAsset,
              fit: widget.fit,
            ),
    );
  }
}

/// Оптимизированный список с ленивой загрузкой
class OptimizedListView extends StatelessWidget {
  final List<Widget> children;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;

  const OptimizedListView({
    super.key,
    required this.children,
    this.controller,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: padding,
      itemCount: children.length,
      itemBuilder: (context, index) {
        return PerformanceUtils.optimizeRebuild(
          children[index],
          Key(PerformanceUtils.createLazyKey('list_item', index)),
        );
      },
    );
  }
}

/// Виджет для кэширования данных
class DataCache<T> extends StatefulWidget {
  final Future<T> Function() fetchData;
  final Widget Function(T data) builder;
  final Widget Function()? loadingBuilder;
  final Widget Function(Object error)? errorBuilder;
  final Duration cacheDuration;

  const DataCache({
    super.key,
    required this.fetchData,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
    this.cacheDuration = const Duration(minutes: 5),
  });

  @override
  State<DataCache<T>> createState() => _DataCacheState<T>();
}

class _DataCacheState<T> extends State<DataCache<T>> {
  T? _cachedData;
  Object? _error;
  bool _isLoading = false;
  DateTime? _lastFetchTime;

  @override
  void initState() {
    super.initState();
    _loadDataIfNeeded();
  }

  Future<void> _loadDataIfNeeded() async {
    final now = DateTime.now();
    final shouldRefresh = _lastFetchTime == null ||
        now.difference(_lastFetchTime!) > widget.cacheDuration;

    if (shouldRefresh || _cachedData == null) {
      await _loadData();
    }
  }

  Future<void> _loadData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await widget.fetchData();
      setState(() {
        _cachedData = data;
        _lastFetchTime = DateTime.now();
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = error;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.loadingBuilder?.call() ?? const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return widget.errorBuilder?.call(_error!) ??
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Ошибка загрузки: $_error'),
                ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('Повторить'),
                ),
              ],
            ),
          );
    }

    if (_cachedData != null) {
      return widget.builder(_cachedData!);
    }

    return const Center(child: CircularProgressIndicator());
  }
}

/// Виджет для предотвращения лишних перерисовок
class OptimizedBuilder extends StatefulWidget {
  final Widget Function(BuildContext context) builder;

  const OptimizedBuilder({
    super.key,
    required this.builder,
  });

  @override
  State<OptimizedBuilder> createState() => _OptimizedBuilderState();
}

class _OptimizedBuilderState extends State<OptimizedBuilder> {
  @override
  Widget build(BuildContext context) {
    return PerformanceUtils.optimizeRebuild(
      widget.builder(context),
    );
  }
}

/// Расширение для удобного использования оптимизаций
extension PerformanceExtensions on Widget {
  /// Оптимизирует виджет для предотвращения лишних перерисовок
  Widget optimized([Key? key]) {
    return PerformanceUtils.optimizeRebuild(this, key);
  }

  /// Добавляет ленивую загрузку для изображений
  Widget lazyImage(String imageUrl, String placeholderAsset, {double? width, double? height, BoxFit? fit}) {
    return LazyImage(
      imageUrl: imageUrl,
      placeholderAsset: placeholderAsset,
      width: width,
      height: height,
      fit: fit,
    );
  }
}

/// Утилита для мониторинга производительности
class PerformanceMonitor {
  static final Map<String, Stopwatch> _timers = {};

  /// Начинает отсчет времени для операции
  static void startTimer(String operationId) {
    _timers[operationId] = Stopwatch()..start();
  }

  /// Останавливает таймер и возвращает время выполнения
  static Duration stopTimer(String operationId) {
    final timer = _timers[operationId];
    if (timer != null) {
      timer.stop();
      final duration = timer.elapsed;
      _timers.remove(operationId);
      
      // Логируем время выполнения для отладки
      debugPrint('⏱️ $operationId выполнена за: ${duration.inMilliseconds}ms');
      
      return duration;
    }
    return Duration.zero;
  }

  /// Измеряет время выполнения функции
  static Future<T> measureExecution<T>(String operationId, Future<T> Function() function) async {
    startTimer(operationId);
    try {
      final result = await function();
      stopTimer(operationId);
      return result;
    } catch (e) {
      stopTimer(operationId);
      rethrow;
    }
  }
}