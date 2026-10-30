import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _db;

  Future<Database> get db async {
    _db ??= await _initialDb();
    return _db!;
  }

  Future<Database> _initialDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'firstDatabase.db');
    return await openDatabase(path, onCreate: _onCreate, version: 1);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Tasks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  description TEXT,
  startAt TEXT NOT NULL,
  endAt TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  priority TEXT NOT NULL DEFAULT 'low',
  category TEXT NOT NULL DEFAULT 'others',
  subtasks TEXT NOT NULL DEFAULT '[]'
)
    ''');
  }

  Future<List<Map<String, Object?>>> readData(
    String sql, [
    List<Object?>? args,
  ]) async {
    final myDb = await db;
    return await myDb.rawQuery(sql, args);
  }

  Future<int> insertData(String table, Map<String, Object?> values) async {
    final myDb = await db;
    return await myDb.insert(table, values);
  }

  Future<int> updateData(String sql, [List<Object?>? args]) async {
    final myDb = await db;
    return await myDb.rawUpdate(sql, args);
  }

  Future<int> deleteData(String sql, [List<Object?>? args]) async {
    final myDb = await db;
    return await myDb.rawDelete(sql, args);
  }
}
