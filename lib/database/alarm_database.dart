import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'alarm_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(
      '''
      CREATE TABLE alarms(
        id INTEGER PRIMARY KEY,
        dateTime TEXT,
        enabled INTEGER
      )
      ''',
    );
  }

  Future<int> insertAlarm(Map<String, dynamic> alarm) async {
    Database db = await database;
    return await db.insert('alarms', alarm);
  }

  Future<int> deleteAlarm(int id) async {
    Database db = await database;
    return await db.delete('alarms', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateAlarm(int id, Map<String, dynamic> alarm) async {
    Database db = await database;
    return await db.update('alarms', alarm, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAlarms() async {
    Database db = await database;
    return await db.query('alarms');
  }
}
