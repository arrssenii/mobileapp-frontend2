// lib/services/emergency_call_database_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../data/models/emergency_call_model.dart';

class EmergencyCallDatabaseService {
  static final EmergencyCallDatabaseService _instance =
      EmergencyCallDatabaseService._internal();
  factory EmergencyCallDatabaseService() => _instance;
  EmergencyCallDatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'emergency_calls.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE emergency_calls (
        id INTEGER PRIMARY KEY,
        number TEXT NOT NULL,
        address TEXT NOT NULL,
        doctor_code TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        templates TEXT NOT NULL, -- Сохраняется как строка, разделённая запятыми
        raw_data TEXT NOT NULL  -- Сохраняется как строка JSON
      )
    ''');
  }

  Future<void> insertCall(EmergencyCall call) async {
    final db = await database;
    await db.insert(
      'emergency_calls',
      call.toDatabaseInsertMap(),
      conflictAlgorithm:
          ConflictAlgorithm.replace, // Заменяем, если ID уже есть
    );
  }

  Future<void> insertCalls(List<EmergencyCall> calls) async {
    final db = await database;
    final batch = db.batch();
    for (final call in calls) {
      batch.insert(
        'emergency_calls',
        call.toDatabaseInsertMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit();
  }

  Future<List<EmergencyCall>> getAllCalls() async {
    final db = await database;
    final maps = await db.query(
      'emergency_calls',
      orderBy: 'created_at DESC',
    ); // Сортируем по дате создания

    return List.generate(maps.length, (i) {
      return EmergencyCall.fromDatabase(maps[i]);
    });
  }

  Future<void> clearAllCalls() async {
    final db = await database;
    await db.delete('emergency_calls');
  }

  // Добавьте другие методы, если нужно (например, получить по ID, по дате, по доктору)
}
