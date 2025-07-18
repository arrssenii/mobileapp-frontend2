import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _storageKey = 'auth_data';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final SharedPreferences? _prefs;

  AuthService(this._prefs);

  // Сохраняем токен в зависимости от платформы
  Future<void> saveToken(String token) async {
    if (kIsWeb) {
      // Для web используем cookies
      final expiration = DateTime.now().add(const Duration(days: 30));
      final cookie = "token=$token; expires=${expiration.toUtc().toIso8601String()}; path=/";
      html.document.cookie = cookie;
      
      // Дополнительно сохраняем в SharedPreferences
      if (_prefs != null) {
        await _prefs!.setString(_tokenKey, token);
      }
    } else {
      // Для мобильных платформ используем Secure Storage
      await _secureStorage.write(key: _tokenKey, value: token);
    }
  }

  // Получаем токен
  Future<String?> getToken() async {
    if (kIsWeb) {
      // Логика для web
      final cookies = html.document.cookie?.split(';') ?? [];
      for (final cookie in cookies) {
        final parts = cookie.split('=');
        if (parts.length == 2 && parts[0].trim() == 'token') {
          return parts[1].trim();
        }
      }
      return _prefs?.getString(_tokenKey);
    } else {
      // Логика для мобильных платформ
      return await _secureStorage.read(key: _tokenKey);
    }
  }

  // Удаляем токен при выходе
  Future<void> deleteToken() async {
    if (kIsWeb) {
      // Удаляем cookie
      html.document.cookie = "token=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;";
      
      // Удаляем из SharedPreferences
      if (_prefs != null) {
        await _prefs!.remove(_tokenKey);
      }
    } else {
      // Для мобильных платформ
      await _secureStorage.delete(key: _tokenKey);
    }
  }
}