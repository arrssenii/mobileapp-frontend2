import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String _callsKey = 'cached_calls';

  // Сохранить вызовы
  static Future<void> saveCalls(List<Map<String, dynamic>> calls) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(calls);
    await prefs.setString(_callsKey, jsonString);
  }

  // Загрузить вызовы
  static Future<List<Map<String, dynamic>>> loadCalls() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_callsKey);
    if (jsonString != null) {
      final list = jsonDecode(jsonString) as List<dynamic>;
      return list.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Очистить кэш
  static Future<void> clearCalls() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_callsKey);
  }
}
