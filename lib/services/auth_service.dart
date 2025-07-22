import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _doctorIdKey = 'doctor_id'; // Ключ для ID доктора
  
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
        await _prefs.setString(_tokenKey, token);
      }
    } else {
      // Для мобильных платформ используем Secure Storage
      await _secureStorage.write(key: _tokenKey, value: token);
    }
  }

  Future<void> saveDoctorId(String doctorId) async {
    if (kIsWeb) {
      final expiration = DateTime.now().add(const Duration(days: 30));
      final cookie = "doctor_id=$doctorId; expires=${expiration.toUtc().toIso8601String()}; path=/";
      html.document.cookie = cookie;
      
      if (_prefs != null) {
        await _prefs?.setString(_doctorIdKey, doctorId);
      }
    } else {
      await _secureStorage.write(key: _doctorIdKey, value: doctorId);
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

  Future<String?> getDoctorId() async {
    if (kIsWeb) {
      final cookies = html.document.cookie?.split(';') ?? [];
      for (final cookie in cookies) {
        final parts = cookie.split('=');
        if (parts.length == 2 && parts[0].trim() == 'doctor_id') {
          return parts[1].trim();
        }
      }
      return _prefs?.getString(_doctorIdKey);
    } else {
      return await _secureStorage.read(key: _doctorIdKey);
    }
  }

  Future<void> clearAll() async {
    await deleteToken();
    await deleteDoctorId();
  }

  // Удаление ID доктора
  Future<void> deleteDoctorId() async {
    if (kIsWeb) {
      html.document.cookie = "doctor_id=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;";
      if (_prefs != null) {
        await _prefs?.remove(_doctorIdKey);
      }
    } else {
      await _secureStorage.delete(key: _doctorIdKey);
    }
  }

  // Удаляем токен при выходе
  Future<void> deleteToken() async {
    if (kIsWeb) {
      // Удаляем cookie
      html.document.cookie = "token=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;";
      
      // Удаляем из SharedPreferences
      if (_prefs != null) {
        await _prefs.remove(_tokenKey);
      }
    } else {
      // Для мобильных платформ
      await _secureStorage.delete(key: _tokenKey);
    }
  }
}